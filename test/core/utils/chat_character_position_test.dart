import 'package:flutter_test/flutter_test.dart';
import 'package:nai_launcher/core/utils/chat_character_position.dart';
import 'package:nai_launcher/data/models/character/character_prompt.dart' as ui;
import 'package:nai_launcher/data/models/image/image_params.dart';

void main() {
  test(
    'custom defaults and old continuous centers snap without changing saved native positions',
    () {
      for (final stored in [false, true]) {
        final original = ui.CharacterPromptConfig(
          characters: [
            for (final (id, x) in [('a', 0.25), ('b', 0.75)])
              ui.CharacterPrompt(
                id: id,
                name: id,
                prompt: id,
                positionMode: stored
                    ? ui.CharacterPositionMode.custom
                    : ui.CharacterPositionMode.aiChoice,
                customPosition: stored
                    ? ui.CharacterPosition(column: x, row: 0.5)
                    : null,
              ),
          ],
        );
        final effective = ChatCharacterPosition.effectiveConfig(original);
        expect(effective.characters.map((c) => c.customPosition!.column), [
          0.3,
          0.7,
        ]);
        expect(
          effective.characters.map(
            (c) => ChatCharacterPosition.grid(
              c.customPosition!.column,
              c.customPosition!.row,
            ),
          ),
          ['B3', 'D3'],
        );
        expect(original.globalAiChoice, true);
        expect(
          original.characters.first.customPosition?.column,
          stored ? 0.25 : null,
        );
        expect(
          original.characters.last.customPosition?.column,
          stored ? 0.75 : null,
        );
        final params = ImageParams(
          useCoords: stored,
          characters: [
            for (final x in [0.25, 0.75])
              CharacterPrompt(
                prompt: 'role',
                positionX: stored ? x : null,
                positionY: stored ? 0.5 : null,
              ),
          ],
        );
        final snapshot = ChatCharacterPosition.effectiveParams(params);
        expect(snapshot.characters.map((c) => c.positionX), [0.3, 0.7]);
        expect(snapshot.characters.map((c) => c.positionY), [0.5, 0.5]);
        expect(params.characters.first.positionX, stored ? 0.25 : null);
        expect(ChatCharacterPosition.effectiveParams(snapshot), snapshot);
      }
    },
  );
  test('all 25 cell centers round-trip to the Chat API grid', () {
    for (var row = 0; row < 5; row++) {
      for (var column = 0; column < 5; column++) {
        final cell = ChatCharacterPosition.cell(column, row);
        expect(
          ChatCharacterPosition.grid(cell.column, cell.row),
          '${String.fromCharCode(65 + column)}${row + 1}',
        );
      }
    }
  });

  test(
    'legacy global AI configuration gets manual defaults without mutation',
    () {
      const original = ui.CharacterPromptConfig(
        characters: [
          ui.CharacterPrompt(id: 'a', name: 'A', prompt: 'girl'),
          ui.CharacterPrompt(
            id: 'b',
            name: 'B',
            prompt: 'boy',
            positionMode: ui.CharacterPositionMode.custom,
            customPosition: ui.CharacterPosition(column: 0.9, row: 0.1),
          ),
        ],
      );
      final effective = ChatCharacterPosition.effectiveConfig(original);
      expect(original.globalAiChoice, true);
      expect(original.characters.first.customPosition, isNull);
      expect(effective.globalAiChoice, false);
      expect(
        effective.characters.first.positionMode,
        ui.CharacterPositionMode.custom,
      );
      expect(effective.characters.last.customPosition?.column, 0.9);
      expect(effective.characters.last.customPosition?.row, 0.1);
    },
  );

  test(
    'legacy AI snapshot keeps valid old centers and fills absent centers',
    () {
      const original = ImageParams(
        characters: [
          CharacterPrompt(prompt: 'girl'),
          CharacterPrompt(prompt: 'boy', positionX: 0.9, positionY: 0.1),
        ],
        useCoords: false,
      );
      final effective = ChatCharacterPosition.effectiveParams(original);
      expect(original.useCoords, false);
      expect(original.characters.first.positionX, isNull);
      expect(effective.useCoords, true);
      expect(effective.characters.first.positionX, 0.3);
      expect(effective.characters.first.positionY, 0.5);
      expect(effective.characters.last.positionX, 0.9);
      expect(effective.characters.last.positionY, 0.1);
    },
  );

  test(
    'invalid explicit manual center still fails instead of being hidden',
    () {
      expect(
        () => ChatCharacterPosition.effectiveParams(
          const ImageParams(
            useCoords: true,
            characters: [CharacterPrompt(prompt: 'girl')],
          ),
        ),
        throwsArgumentError,
      );
    },
  );
}
