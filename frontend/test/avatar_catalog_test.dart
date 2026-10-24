import 'package:flutter_test/flutter_test.dart';
import 'package:nutriview/shared/neo/avatar_catalog.dart';

void main() {
  group('AvatarCatalog Tests', () {
    test('contains exactly 8 unique game character definitions', () {
      expect(AvatarCatalog.allCharacters.length, equals(8));
      final ids = AvatarCatalog.allCharacters.map((c) => c.id).toSet();
      expect(ids.length, equals(8));
    });

    test('default avatar is chef_pro', () {
      expect(AvatarCatalog.defaultAvatarId, equals('chef_pro'));
      final defaultChar = AvatarCatalog.getById(AvatarCatalog.defaultAvatarId);
      expect(defaultChar.name, equals('Master Koki'));
    });

    test('finds existing characters by valid ID', () {
      for (final char in AvatarCatalog.allCharacters) {
        final found = AvatarCatalog.getById(char.id);
        expect(found.id, equals(char.id));
        expect(found.name, equals(char.name));
        expect(found.title, equals(char.title));
        expect(found.traits.isNotEmpty, isTrue);
      }
    });

    test('falls back to default character for unknown or null ID', () {
      final forNull = AvatarCatalog.getById(null);
      expect(forNull.id, equals('chef_pro'));

      final forUnknown = AvatarCatalog.getById('non_existent_hero_999');
      expect(forUnknown.id, equals('chef_pro'));
    });

    test('migrates legacy color presets seamlessly', () {
      expect(AvatarCatalog.getById('lime').id, equals('runner_ace'));
      expect(AvatarCatalog.getById('cobalt').id, equals('cyber_gamer'));
      expect(AvatarCatalog.getById('tangerine').id, equals('retro_pixel'));
      expect(AvatarCatalog.getById('lilac').id, equals('scholar_doc'));
    });

    test('isValidId accurately verifies ID existence and legacy support', () {
      expect(AvatarCatalog.isValidId('chef_pro'), isTrue);
      expect(AvatarCatalog.isValidId('runner_ace'), isTrue);
      expect(AvatarCatalog.isValidId('cyber_gamer'), isTrue);
      expect(AvatarCatalog.isValidId('scholar_doc'), isTrue);
      expect(AvatarCatalog.isValidId('botanist_green'), isTrue);
      expect(AvatarCatalog.isValidId('retro_pixel'), isTrue);
      expect(AvatarCatalog.isValidId('yoga_zen'), isTrue);
      expect(AvatarCatalog.isValidId('space_voyager'), isTrue);

      // Legacy presets
      expect(AvatarCatalog.isValidId('lime'), isTrue);
      expect(AvatarCatalog.isValidId('cobalt'), isTrue);

      // Invalid
      expect(AvatarCatalog.isValidId('invalid'), isFalse);
      expect(AvatarCatalog.isValidId(null), isFalse);
    });
  });
}
