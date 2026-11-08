import 'package:flutter/material.dart';
import 'package:oopsieeats/core/neo_tokens.dart';

/// Representation of a built-in game-style Neo-Brutalism avatar character.
class GameAvatarCharacter {
  final String id;
  final String name;
  final String title;
  final String traits;
  final Color backgroundColor;
  final Color accentColor;
  final Widget Function(double size) builder;

  const GameAvatarCharacter({
    required this.id,
    required this.name,
    required this.title,
    required this.traits,
    required this.backgroundColor,
    required this.accentColor,
    required this.builder,
  });
}

/// Catalog of authentic, distinct game-style avatars for NutriView users.
/// strictly ZERO photo uploads for user avatars; characters have distinct
/// expressions, headwear, hairstyles, outfits, and silhouettes.
class AvatarCatalog {
  static const String defaultAvatarId = 'chef_pro';

  static final List<GameAvatarCharacter> characters = [
    GameAvatarCharacter(
      id: 'chef_pro',
      name: 'Master Koki',
      title: 'Ahli Kuliner Sehat',
      traits: 'Topi Koki Tinggi · Celemek Dapur · Kumis Khas',
      backgroundColor: NeoTokens.vividYellow,
      accentColor: NeoTokens.black,
      builder: (size) => _ChefAvatarPainterWidget(size: size),
    ),
    GameAvatarCharacter(
      id: 'runner_ace',
      name: 'Pelari Tangguh',
      title: 'Atlet Kebugaran',
      traits: 'Headband Atletik · Kacamata Sporty · Jersey Neon',
      backgroundColor: NeoTokens.mintGreen,
      accentColor: NeoTokens.black,
      builder: (size) => _RunnerAvatarPainterWidget(size: size),
    ),
    GameAvatarCharacter(
      id: 'cyber_gamer',
      name: 'Cyber Hero',
      title: 'Pecinta Teknologi',
      traits: 'Headset Over-Ear · Visor Cyberpunk · Jaket Hoodie',
      backgroundColor: NeoTokens.skyBlue,
      accentColor: NeoTokens.black,
      builder: (size) => _CyberAvatarPainterWidget(size: size),
    ),
    GameAvatarCharacter(
      id: 'scholar_doc',
      name: 'Ahli Gizi',
      title: 'Peneliti Nutrisi',
      traits: 'Kacamata Bulat · Jas Laboratorium · Dasi Kupu-Kupu',
      backgroundColor: NeoTokens.lavender,
      accentColor: NeoTokens.black,
      builder: (size) => _ScholarAvatarPainterWidget(size: size),
    ),
    GameAvatarCharacter(
      id: 'botanist_green',
      name: 'Pencinta Alam',
      title: 'Pakar Pangan Nabati',
      traits: 'Bucket Hat Safari · Daun Semanggi · Kemeja Petualang',
      backgroundColor: const Color(0xFF6EE7B7),
      accentColor: NeoTokens.black,
      builder: (size) => _BotanistAvatarPainterWidget(size: size),
    ),
    GameAvatarCharacter(
      id: 'retro_pixel',
      name: 'Retro Biker',
      title: 'Petualang Jalanan',
      traits: 'Bandana Merah · Rambut Spike 90s · Jaket Kulit',
      backgroundColor: NeoTokens.orangeCarb,
      accentColor: NeoTokens.black,
      builder: (size) => _RetroAvatarPainterWidget(size: size),
    ),
    GameAvatarCharacter(
      id: 'yoga_zen',
      name: 'Zen Master',
      title: 'Keseimbangan Hidup',
      traits: 'Ikat Kepala Meditasi · Raut Tenang · Busana Rileks',
      backgroundColor: const Color(0xFFFED7AA),
      accentColor: NeoTokens.black,
      builder: (size) => _ZenAvatarPainterWidget(size: size),
    ),
    GameAvatarCharacter(
      id: 'space_voyager',
      name: 'Penjelajah Bintang',
      title: 'Pionir Nutrisi Masa Depan',
      traits: 'Helm Astronot · Visor Emas · Kerah Antariksa',
      backgroundColor: const Color(0xFFC084FC),
      accentColor: NeoTokens.black,
      builder: (size) => _SpaceAvatarPainterWidget(size: size),
    ),
  ];

  /// Resolves an avatar character by ID with backward compatibility for legacy color preset names.
  static GameAvatarCharacter getById(String? id) {
    if (id == null || id.trim().isEmpty) {
      return characters.firstWhere((c) => c.id == defaultAvatarId);
    }
    final clean = id.trim().toLowerCase();

    // Direct match
    for (final char in characters) {
      if (char.id == clean) return char;
    }

    // Legacy preset mapping
    switch (clean) {
      case 'lime':
        return characters.firstWhere((c) => c.id == 'runner_ace');
      case 'cobalt':
        return characters.firstWhere((c) => c.id == 'cyber_gamer');
      case 'tangerine':
        return characters.firstWhere((c) => c.id == 'retro_pixel');
      case 'lilac':
        return characters.firstWhere((c) => c.id == 'scholar_doc');
      default:
        return characters.firstWhere((c) => c.id == defaultAvatarId);
    }
  }

  /// All available character definitions.
  static List<GameAvatarCharacter> get allCharacters => characters;

  /// Checks if [id] is a valid registered character ID or recognized legacy preset.
  static bool isValidId(String? id) {
    if (id == null || id.trim().isEmpty) return false;
    final clean = id.trim().toLowerCase();
    const legacy = {'lime', 'cobalt', 'tangerine', 'lilac'};
    if (legacy.contains(clean)) return true;
    return characters.any((c) => c.id == clean);
  }
}

// ============================================================================
// VECTOR CHARACTER CUSTOM PAINTER WIDGETS
// Clean, bold Neo-Brutalism line art and distinct geometry
// ============================================================================

class _ChefAvatarPainterWidget extends StatelessWidget {
  final double size;
  const _ChefAvatarPainterWidget({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _ChefPainter());
  }
}

class _ChefPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    final stroke = Paint()
      ..color = NeoTokens.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillWhite = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final fillSkin = Paint()
      ..color = const Color(0xFFFCD34D)
      ..style = PaintingStyle.fill;
    final fillRed = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    final fillBlack = Paint()
      ..color = NeoTokens.black
      ..style = PaintingStyle.fill;

    // Body / Outfit (White double-breasted chef coat)
    final coatPath = Path()
      ..moveTo(20 * scale, 100 * scale)
      ..lineTo(20 * scale, 75 * scale)
      ..lineTo(80 * scale, 75 * scale)
      ..lineTo(80 * scale, 100 * scale)
      ..close();
    canvas.drawPath(coatPath, fillWhite);
    canvas.drawPath(coatPath, stroke);

    // Red neckerchief
    final scarfPath = Path()
      ..moveTo(40 * scale, 75 * scale)
      ..lineTo(50 * scale, 86 * scale)
      ..lineTo(60 * scale, 75 * scale)
      ..close();
    canvas.drawPath(scarfPath, fillRed);
    canvas.drawPath(scarfPath, stroke);

    // Head / Face
    final faceRect = Rect.fromCenter(
      center: Offset(50 * scale, 56 * scale),
      width: 44 * scale,
      height: 38 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, Radius.circular(10 * scale)),
      fillSkin,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, Radius.circular(10 * scale)),
      stroke,
    );

    // Chef Hat Top Puffs
    final hatPath = Path()
      ..moveTo(28 * scale, 38 * scale)
      ..cubicTo(
        20 * scale,
        16 * scale,
        42 * scale,
        10 * scale,
        50 * scale,
        20 * scale,
      )
      ..cubicTo(
        58 * scale,
        10 * scale,
        80 * scale,
        16 * scale,
        72 * scale,
        38 * scale,
      )
      ..close();
    canvas.drawPath(hatPath, fillWhite);
    canvas.drawPath(hatPath, stroke);

    // Chef Hat Band
    final hatBand = Rect.fromLTWH(
      26 * scale,
      34 * scale,
      48 * scale,
      10 * scale,
    );
    canvas.drawRect(hatBand, fillWhite);
    canvas.drawRect(hatBand, stroke);

    // Eyes
    canvas.drawCircle(Offset(42 * scale, 52 * scale), 2.5 * scale, fillBlack);
    canvas.drawCircle(Offset(58 * scale, 52 * scale), 2.5 * scale, fillBlack);

    // Chef Moustache
    final moustache = Path()
      ..moveTo(36 * scale, 62 * scale)
      ..quadraticBezierTo(44 * scale, 58 * scale, 50 * scale, 64 * scale)
      ..quadraticBezierTo(56 * scale, 58 * scale, 64 * scale, 62 * scale)
      ..quadraticBezierTo(50 * scale, 69 * scale, 36 * scale, 62 * scale);
    canvas.drawPath(moustache, fillBlack);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RunnerAvatarPainterWidget extends StatelessWidget {
  final double size;
  const _RunnerAvatarPainterWidget({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _RunnerPainter());
  }
}

class _RunnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    final stroke = Paint()
      ..color = NeoTokens.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillSkin = Paint()
      ..color = const Color(0xFFFDBA74)
      ..style = PaintingStyle.fill;
    final fillShirt = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;
    final fillBand = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    final fillVisor = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    final fillHair = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.fill;

    // Athletic Jersey
    final jerseyPath = Path()
      ..moveTo(18 * scale, 100 * scale)
      ..lineTo(22 * scale, 74 * scale)
      ..lineTo(78 * scale, 74 * scale)
      ..lineTo(82 * scale, 100 * scale)
      ..close();
    canvas.drawPath(jerseyPath, fillShirt);
    canvas.drawPath(jerseyPath, stroke);

    // Jersey collar racing stripes
    final stripe = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * scale;
    canvas.drawLine(
      Offset(44 * scale, 74 * scale),
      Offset(44 * scale, 100 * scale),
      stripe,
    );
    canvas.drawLine(
      Offset(56 * scale, 74 * scale),
      Offset(56 * scale, 100 * scale),
      stripe,
    );

    // Spiky Hair in background
    final hairPath = Path()
      ..moveTo(26 * scale, 36 * scale)
      ..lineTo(32 * scale, 16 * scale)
      ..lineTo(44 * scale, 22 * scale)
      ..lineTo(54 * scale, 14 * scale)
      ..lineTo(64 * scale, 24 * scale)
      ..lineTo(74 * scale, 18 * scale)
      ..lineTo(76 * scale, 40 * scale)
      ..close();
    canvas.drawPath(hairPath, fillHair);
    canvas.drawPath(hairPath, stroke);

    // Head
    final faceRect = Rect.fromCenter(
      center: Offset(50 * scale, 52 * scale),
      width: 42 * scale,
      height: 38 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, Radius.circular(8 * scale)),
      fillSkin,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, Radius.circular(8 * scale)),
      stroke,
    );

    // Athletic Headband
    final bandRect = Rect.fromLTWH(
      26 * scale,
      30 * scale,
      48 * scale,
      9 * scale,
    );
    canvas.drawRect(bandRect, fillBand);
    canvas.drawRect(bandRect, stroke);

    // Sporty Sunglasses / Visor
    final glassesRect = Rect.fromLTWH(
      30 * scale,
      46 * scale,
      40 * scale,
      12 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(glassesRect, Radius.circular(3 * scale)),
      fillVisor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(glassesRect, Radius.circular(3 * scale)),
      stroke,
    );

    // Visor reflection line
    final refl = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scale;
    canvas.drawLine(
      Offset(34 * scale, 52 * scale),
      Offset(46 * scale, 52 * scale),
      refl,
    );

    // Determined grin
    canvas.drawLine(
      Offset(44 * scale, 65 * scale),
      Offset(56 * scale, 65 * scale),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CyberAvatarPainterWidget extends StatelessWidget {
  final double size;
  const _CyberAvatarPainterWidget({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _CyberPainter());
  }
}

class _CyberPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    final stroke = Paint()
      ..color = NeoTokens.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillHoodie = Paint()
      ..color = const Color(0xFF3B82F6)
      ..style = PaintingStyle.fill;
    final fillSkin = Paint()
      ..color = const Color(0xFFFED7AA)
      ..style = PaintingStyle.fill;
    final fillCyberVisor = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;
    final fillHeadset = Paint()
      ..color = const Color(0xFF1E1E2E)
      ..style = PaintingStyle.fill;

    // Hoodie
    final hoodie = Path()
      ..moveTo(16 * scale, 100 * scale)
      ..lineTo(22 * scale, 72 * scale)
      ..lineTo(78 * scale, 72 * scale)
      ..lineTo(84 * scale, 100 * scale)
      ..close();
    canvas.drawPath(hoodie, fillHoodie);
    canvas.drawPath(hoodie, stroke);

    // Head
    final faceRect = Rect.fromCenter(
      center: Offset(50 * scale, 52 * scale),
      width: 40 * scale,
      height: 38 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, Radius.circular(8 * scale)),
      fillSkin,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, Radius.circular(8 * scale)),
      stroke,
    );

    // Headset band over head
    final headBand = Path()
      ..moveTo(22 * scale, 50 * scale)
      ..quadraticBezierTo(50 * scale, 14 * scale, 78 * scale, 50 * scale);
    final bandStroke = Paint()
      ..color = NeoTokens.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * scale;
    canvas.drawPath(headBand, bandStroke);

    // Ear cups
    final leftCup = Rect.fromCenter(
      center: Offset(26 * scale, 52 * scale),
      width: 10 * scale,
      height: 22 * scale,
    );
    final rightCup = Rect.fromCenter(
      center: Offset(74 * scale, 52 * scale),
      width: 10 * scale,
      height: 22 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(leftCup, Radius.circular(4 * scale)),
      fillHeadset,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(leftCup, Radius.circular(4 * scale)),
      stroke,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rightCup, Radius.circular(4 * scale)),
      fillHeadset,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rightCup, Radius.circular(4 * scale)),
      stroke,
    );

    // Cyber visor
    final visor = Rect.fromLTWH(32 * scale, 44 * scale, 36 * scale, 12 * scale);
    canvas.drawRect(visor, fillCyberVisor);
    canvas.drawRect(visor, stroke);

    // Visor HUD text
    final hudP = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(36 * scale, 48 * scale, 8 * scale, 4 * scale),
      hudP,
    );
    canvas.drawRect(
      Rect.fromLTWH(48 * scale, 48 * scale, 12 * scale, 4 * scale),
      hudP,
    );

    // Smirk
    canvas.drawLine(
      Offset(45 * scale, 64 * scale),
      Offset(55 * scale, 62 * scale),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScholarAvatarPainterWidget extends StatelessWidget {
  final double size;
  const _ScholarAvatarPainterWidget({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _ScholarPainter());
  }
}

class _ScholarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    final stroke = Paint()
      ..color = NeoTokens.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillLab = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final fillSkin = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.fill;
    final fillHair = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.fill;
    final fillTie = Paint()
      ..color = const Color(0xFF7C3AED)
      ..style = PaintingStyle.fill;

    // Lab Coat
    final coat = Path()
      ..moveTo(18 * scale, 100 * scale)
      ..lineTo(24 * scale, 74 * scale)
      ..lineTo(76 * scale, 74 * scale)
      ..lineTo(82 * scale, 100 * scale)
      ..close();
    canvas.drawPath(coat, fillLab);
    canvas.drawPath(coat, stroke);

    // Bow tie
    final bowTie = Path()
      ..moveTo(44 * scale, 74 * scale)
      ..lineTo(56 * scale, 80 * scale)
      ..lineTo(56 * scale, 74 * scale)
      ..lineTo(44 * scale, 80 * scale)
      ..close();
    canvas.drawPath(bowTie, fillTie);
    canvas.drawPath(bowTie, stroke);

    // Hair base
    final hair = Path()
      ..moveTo(24 * scale, 46 * scale)
      ..cubicTo(
        20 * scale,
        20 * scale,
        80 * scale,
        20 * scale,
        76 * scale,
        46 * scale,
      )
      ..close();
    canvas.drawPath(hair, fillHair);
    canvas.drawPath(hair, stroke);

    // Face
    final faceRect = Rect.fromCenter(
      center: Offset(50 * scale, 52 * scale),
      width: 42 * scale,
      height: 36 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, Radius.circular(8 * scale)),
      fillSkin,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, Radius.circular(8 * scale)),
      stroke,
    );

    // Round Glasses
    final leftGlass = Rect.fromCircle(
      center: Offset(41 * scale, 50 * scale),
      radius: 7 * scale,
    );
    final rightGlass = Rect.fromCircle(
      center: Offset(59 * scale, 50 * scale),
      radius: 7 * scale,
    );
    canvas.drawOval(leftGlass, stroke);
    canvas.drawOval(rightGlass, stroke);
    canvas.drawLine(
      Offset(48 * scale, 50 * scale),
      Offset(52 * scale, 50 * scale),
      stroke,
    );

    // Eyes inside glasses
    final fillB = Paint()
      ..color = NeoTokens.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(41 * scale, 50 * scale), 2 * scale, fillB);
    canvas.drawCircle(Offset(59 * scale, 50 * scale), 2 * scale, fillB);

    // Friendly smile
    final smile = Path()
      ..moveTo(45 * scale, 62 * scale)
      ..quadraticBezierTo(50 * scale, 66 * scale, 55 * scale, 62 * scale);
    canvas.drawPath(smile, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BotanistAvatarPainterWidget extends StatelessWidget {
  final double size;
  const _BotanistAvatarPainterWidget({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _BotanistPainter());
  }
}

class _BotanistPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    final stroke = Paint()
      ..color = NeoTokens.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillSkin = Paint()
      ..color = const Color(0xFFFDBA74)
      ..style = PaintingStyle.fill;
    final fillHat = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    final fillShirt = Paint()
      ..color = const Color(0xFF059669)
      ..style = PaintingStyle.fill;
    final fillLeaf = Paint()
      ..color = const Color(0xFF84CC16)
      ..style = PaintingStyle.fill;

    // Outdoor Shirt
    final shirt = Path()
      ..moveTo(18 * scale, 100 * scale)
      ..lineTo(24 * scale, 74 * scale)
      ..lineTo(76 * scale, 74 * scale)
      ..lineTo(82 * scale, 100 * scale)
      ..close();
    canvas.drawPath(shirt, fillShirt);
    canvas.drawPath(shirt, stroke);

    // Face
    final faceRect = Rect.fromCenter(
      center: Offset(50 * scale, 56 * scale),
      width: 42 * scale,
      height: 36 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, Radius.circular(8 * scale)),
      fillSkin,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, Radius.circular(8 * scale)),
      stroke,
    );

    // Bucket Hat Crown
    final hatCrown = Path()
      ..moveTo(30 * scale, 42 * scale)
      ..lineTo(34 * scale, 22 * scale)
      ..lineTo(66 * scale, 22 * scale)
      ..lineTo(70 * scale, 42 * scale)
      ..close();
    canvas.drawPath(hatCrown, fillHat);
    canvas.drawPath(hatCrown, stroke);

    // Bucket Hat Brim
    final hatBrim = Rect.fromLTWH(
      20 * scale,
      38 * scale,
      60 * scale,
      10 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(hatBrim, Radius.circular(4 * scale)),
      fillHat,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(hatBrim, Radius.circular(4 * scale)),
      stroke,
    );

    // Leaf decoration on hat
    final leaf = Path()
      ..moveTo(64 * scale, 34 * scale)
      ..quadraticBezierTo(72 * scale, 28 * scale, 70 * scale, 20 * scale)
      ..quadraticBezierTo(60 * scale, 26 * scale, 64 * scale, 34 * scale);
    canvas.drawPath(leaf, fillLeaf);
    canvas.drawPath(leaf, stroke);

    // Eyes
    final fillB = Paint()
      ..color = NeoTokens.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(42 * scale, 55 * scale), 2.5 * scale, fillB);
    canvas.drawCircle(Offset(58 * scale, 55 * scale), 2.5 * scale, fillB);

    // Gentle smile
    final smile = Path()
      ..moveTo(45 * scale, 64 * scale)
      ..quadraticBezierTo(50 * scale, 68 * scale, 55 * scale, 64 * scale);
    canvas.drawPath(smile, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RetroAvatarPainterWidget extends StatelessWidget {
  final double size;
  const _RetroAvatarPainterWidget({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _RetroPainter());
  }
}

class _RetroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    final stroke = Paint()
      ..color = NeoTokens.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillSkin = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.fill;
    final fillBandana = Paint()
      ..color = const Color(0xFFDC2626)
      ..style = PaintingStyle.fill;
    final fillJacket = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    final fillHair = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    // Leather Jacket
    final jacket = Path()
      ..moveTo(18 * scale, 100 * scale)
      ..lineTo(24 * scale, 74 * scale)
      ..lineTo(76 * scale, 74 * scale)
      ..lineTo(82 * scale, 100 * scale)
      ..close();
    canvas.drawPath(jacket, fillJacket);
    canvas.drawPath(jacket, stroke);

    // Spiky 90s anime hair
    final hair = Path()
      ..moveTo(22 * scale, 40 * scale)
      ..lineTo(20 * scale, 18 * scale)
      ..lineTo(36 * scale, 24 * scale)
      ..lineTo(48 * scale, 12 * scale)
      ..lineTo(62 * scale, 22 * scale)
      ..lineTo(78 * scale, 14 * scale)
      ..lineTo(78 * scale, 40 * scale)
      ..close();
    canvas.drawPath(hair, fillHair);
    canvas.drawPath(hair, stroke);

    // Face
    final faceRect = Rect.fromCenter(
      center: Offset(50 * scale, 54 * scale),
      width: 42 * scale,
      height: 36 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, Radius.circular(8 * scale)),
      fillSkin,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, Radius.circular(8 * scale)),
      stroke,
    );

    // Red Bandana
    final bandana = Rect.fromLTWH(
      26 * scale,
      34 * scale,
      48 * scale,
      10 * scale,
    );
    canvas.drawRect(bandana, fillBandana);
    canvas.drawRect(bandana, stroke);

    // Bandana knot hanging
    final knot = Path()
      ..moveTo(26 * scale, 40 * scale)
      ..lineTo(18 * scale, 52 * scale)
      ..lineTo(24 * scale, 54 * scale)
      ..close();
    canvas.drawPath(knot, fillBandana);
    canvas.drawPath(knot, stroke);

    // Angular eyes
    final fillB = Paint()
      ..color = NeoTokens.black
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(38 * scale, 52 * scale, 6 * scale, 3 * scale),
      fillB,
    );
    canvas.drawRect(
      Rect.fromLTWH(56 * scale, 52 * scale, 6 * scale, 3 * scale),
      fillB,
    );

    // Confident smirk
    canvas.drawLine(
      Offset(44 * scale, 64 * scale),
      Offset(56 * scale, 62 * scale),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ZenAvatarPainterWidget extends StatelessWidget {
  final double size;
  const _ZenAvatarPainterWidget({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _ZenPainter());
  }
}

class _ZenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    final stroke = Paint()
      ..color = NeoTokens.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillSkin = Paint()
      ..color = const Color(0xFFFDBA74)
      ..style = PaintingStyle.fill;
    final fillRobe = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.fill;
    final fillBand = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Zen Robe
    final robe = Path()
      ..moveTo(18 * scale, 100 * scale)
      ..lineTo(26 * scale, 74 * scale)
      ..lineTo(74 * scale, 74 * scale)
      ..lineTo(82 * scale, 100 * scale)
      ..close();
    canvas.drawPath(robe, fillRobe);
    canvas.drawPath(robe, stroke);

    // Face
    final faceRect = Rect.fromCenter(
      center: Offset(50 * scale, 50 * scale),
      width: 44 * scale,
      height: 42 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, Radius.circular(12 * scale)),
      fillSkin,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, Radius.circular(12 * scale)),
      stroke,
    );

    // Meditation headband
    final band = Rect.fromLTWH(26 * scale, 30 * scale, 48 * scale, 8 * scale);
    canvas.drawRect(band, fillBand);
    canvas.drawRect(band, stroke);

    // Peaceful closed smiling eyes (arcs)
    final eyeLeft = Path()
      ..moveTo(38 * scale, 48 * scale)
      ..quadraticBezierTo(43 * scale, 44 * scale, 48 * scale, 48 * scale);
    final eyeRight = Path()
      ..moveTo(52 * scale, 48 * scale)
      ..quadraticBezierTo(57 * scale, 44 * scale, 62 * scale, 48 * scale);
    canvas.drawPath(eyeLeft, stroke);
    canvas.drawPath(eyeRight, stroke);

    // Serene Smile
    final smile = Path()
      ..moveTo(44 * scale, 58 * scale)
      ..quadraticBezierTo(50 * scale, 63 * scale, 56 * scale, 58 * scale);
    canvas.drawPath(smile, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SpaceAvatarPainterWidget extends StatelessWidget {
  final double size;
  const _SpaceAvatarPainterWidget({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _SpacePainter());
  }
}

class _SpacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    final stroke = Paint()
      ..color = NeoTokens.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillSuit = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final fillVisor = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.fill;
    final fillCollar = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.fill;

    // Space suit shoulders
    final suit = Path()
      ..moveTo(16 * scale, 100 * scale)
      ..lineTo(22 * scale, 74 * scale)
      ..lineTo(78 * scale, 74 * scale)
      ..lineTo(84 * scale, 100 * scale)
      ..close();
    canvas.drawPath(suit, fillSuit);
    canvas.drawPath(suit, stroke);

    // Space Collar
    final collar = Rect.fromLTWH(30 * scale, 70 * scale, 40 * scale, 8 * scale);
    canvas.drawRRect(
      RRect.fromRectAndRadius(collar, Radius.circular(4 * scale)),
      fillCollar,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(collar, Radius.circular(4 * scale)),
      stroke,
    );

    // Astronaut Helmet Dome
    final helmet = Rect.fromCenter(
      center: Offset(50 * scale, 46 * scale),
      width: 52 * scale,
      height: 48 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(helmet, Radius.circular(16 * scale)),
      fillSuit,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(helmet, Radius.circular(16 * scale)),
      stroke,
    );

    // Golden reflective visor
    final visor = Rect.fromCenter(
      center: Offset(50 * scale, 46 * scale),
      width: 38 * scale,
      height: 28 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(visor, Radius.circular(10 * scale)),
      fillVisor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(visor, Radius.circular(10 * scale)),
      stroke,
    );

    // Visor gleam
    final gleam = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * scale;
    canvas.drawLine(
      Offset(40 * scale, 38 * scale),
      Offset(46 * scale, 44 * scale),
      gleam,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
