import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:oopsieeats/core/app_icons.dart';

/// Machine-checked version of the NutriView design-system rules documented in
/// `lib/core/app_icons.dart`. These fail the build when a second icon family,
/// an off-scale icon size or a random font size is reintroduced on any screen
/// (user or admin).
void main() {
  final libDir = Directory('lib');
  final dartFiles =
      libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  final sources = <String, String>{
    for (final file in dartFiles) file.path: file.readAsStringSync(),
  };

  // Every numeric literal allowed for an icon canvas / touch target.
  const iconScale = {12, 14, 16, 18, 20, 22, 24, 28, 32, 36, 40, 44, 110};
  const avatarCanvas = {64, 96}; // NeoAvatar canvases, deliberately not icons.

  // Every numeric literal allowed for text.
  const typeScale = {
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    20,
    22,
    24,
    26,
    34,
  };

  Iterable<Match> matches(String src, RegExp regExp) => regExp.allMatches(src);

  test('lib/ has a single icon source: no raw Icons.* outside AppIcons', () {
    final offenders = <String>[];
    sources.forEach((path, src) {
      if (path == 'lib/core/app_icons.dart') return;
      for (final match in matches(src, RegExp(r'\bIcons\.[A-Za-z0-9_]+'))) {
        offenders.add('$path -> ${match.group(0)}');
      }
    });
    expect(
      offenders,
      isEmpty,
      reason:
          'Import AppIcons (lib/core/app_icons.dart) instead: '
          '${offenders.join(', ')}',
    );
  });

  test('every AppIcons glyph is declared in the Material Rounded family', () {
    final source = sources['lib/core/app_icons.dart']!;
    final declarations = matches(
      source,
      RegExp(r'static const IconData \w+ = (Icons\.\w+);'),
    );
    expect(declarations, isNotEmpty);

    final offFamily = declarations
        .map((m) => m.group(1)!)
        .where((value) => !value.endsWith('_rounded'))
        .toList();
    expect(
      offFamily,
      isEmpty,
      reason: 'Only Icons.<name>_rounded is allowed: ${offFamily.join(', ')}',
    );
  });

  test('no Cupertino icons and no emoji anywhere in lib/', () {
    bool hasEmoji(String text) => text.runes.any(
      (r) =>
          (r >= 0x1F300 && r <= 0x1FAFF) || // pictographs & emoticons
          (r >= 0x2600 && r <= 0x27BF) || // misc symbols & dingbats
          (r >= 0x1F000 && r <= 0x1F2FF) || // misc symbols & transport
          r == 0xFE0F, // emoji variation selector
    );

    final cupertino = <String>[];
    final emoji = <String>[];
    sources.forEach((path, src) {
      if (src.contains('CupertinoIcons') || src.contains('cupertino/icons')) {
        cupertino.add(path);
      }
      if (hasEmoji(src)) emoji.add(path);
    });
    expect(cupertino, isEmpty, reason: 'NutriView uses Material Icons only');
    expect(emoji, isEmpty, reason: 'Zero-emoji policy: $emoji');
  });

  test('Icon(...) sizes always come from an AppIcons size token', () {
    Iterable<Match> iconCalls(String src) =>
        matches(src, RegExp(r'\bIcon\(', multiLine: false));

    String balancedCall(String src, int start) {
      var depth = 0;
      var index = start;
      while (index < src.length) {
        final char = src[index];
        if (char == '(') {
          depth++;
        } else if (char == ')') {
          depth--;
          if (depth == 0) return src.substring(start, index + 1);
        } else if (char == "'") {
          index++;
          while (index < src.length && src[index] != "'") {
            index++;
          }
        }
        index++;
      }
      return '';
    }

    final offenders = <String>[];
    sources.forEach((path, src) {
      if (path == 'lib/core/app_icons.dart') return;
      for (final match in iconCalls(src)) {
        final body = balancedCall(src, match.start);
        final literal = RegExp(r'\bsize:\s*[0-9]+').firstMatch(body);
        if (literal != null) offenders.add('$path -> $body');
      }
    });
    expect(
      offenders,
      isEmpty,
      reason:
          'Use an AppIcons.size* role token instead of a raw number: '
          '${offenders.take(3).join(' | ')}',
    );
  });

  test('every literal icon size is on the design-system scale', () {
    final offenders = <String>[];
    final pattern = RegExp(r'\b(?:size|iconSize):\s*([0-9]+(?:\.[0-9]+)?)');
    sources.forEach((path, src) {
      for (final match in matches(src, pattern)) {
        final value = double.parse(match.group(1)!);
        final isInt = value == value.truncateToDouble();
        final allowed =
            isInt &&
            (iconScale.contains(value.toInt()) ||
                avatarCanvas.contains(value.toInt()));
        if (!allowed) offenders.add('$path -> ${match.group(0)}');
      }
    });
    expect(
      offenders,
      isEmpty,
      reason: 'Off-scale icon sizes: ${offenders.join(', ')}',
    );
  });

  test('every literal font size is an integer on the type scale', () {
    final offenders = <String>[];
    final pattern = RegExp(r'\bfontSize\s*[:=]\s*([0-9]+(?:\.[0-9]+)?)');
    sources.forEach((path, src) {
      for (final match in matches(src, pattern)) {
        final raw = match.group(1)!;
        final value = double.parse(raw);
        if (raw.contains('.') || !typeScale.contains(value.toInt())) {
          offenders.add('$path -> ${match.group(0)}');
        }
      }
    });
    expect(
      offenders,
      isEmpty,
      reason: 'Off-scale font sizes: ${offenders.join(', ')}',
    );
  });

  test('AppIcons size tokens cover the whole icon scale', () {
    final tokenValues = {
      AppIcons.sizeMicro,
      AppIcons.sizeSmall,
      AppIcons.sizeMedium,
      AppIcons.sizeLarge,
      AppIcons.sizeControl,
      AppIcons.sizeToolbar,
      AppIcons.sizeHeader,
      AppIcons.sizeState,
      AppIcons.sizeStateLarge,
      AppIcons.sizeEmpty,
      AppIcons.sizeFeature,
      AppIcons.sizeBrand,
      AppIcons.sizeIllustration,
    }.map((v) => v.toInt()).toSet();

    expect(
      iconScale.difference(tokenValues),
      isEmpty,
      reason: 'Scale values without a token',
    );
    expect(
      tokenValues.difference(iconScale),
      isEmpty,
      reason: 'Tokens outside the documented scale',
    );
    expect(AppIcons.sizeControl, 20, reason: 'standard interactive icon size');
  });
}
