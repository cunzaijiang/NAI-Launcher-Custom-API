import '../../data/models/character/character_prompt.dart' as ui;
import '../../data/models/image/image_params.dart';
import 'character_center_resolver.dart';

/// Custom Chat drawing uses manual A1–E5 positions. Keep the editor's native
/// NovelAI AI-layout preference intact and normalize only the effective snapshot.
abstract final class ChatCharacterPosition {
  static ui.CharacterPromptConfig effectiveConfig(
    ui.CharacterPromptConfig config,
  ) {
    final manual = config
        .copyWith(globalAiChoice: false)
        .normalizeCustomPositions();
    return manual.copyWith(
      characters: [
        for (final character in manual.characters)
          character.copyWith(
            positionMode: ui.CharacterPositionMode.custom,
            customPosition: _snap(manual.resolvePosition(character)),
          ),
      ],
    );
  }

  static ui.CharacterPosition _snap(ui.CharacterPosition position) => cell(
    ((position.column - 0.1) / 0.2).round().clamp(0, 4),
    ((position.row - 0.1) / 0.2).round().clamp(0, 4),
  );

  static String grid(double x, double y) {
    final column = ((x - 0.1) / 0.2).round().clamp(0, 4);
    final row = ((y - 0.1) / 0.2).round().clamp(0, 4);
    return '${String.fromCharCode(65 + column)}${row + 1}';
  }

  static ui.CharacterPosition cell(int column, int row) => ui.CharacterPosition(
    mode: ui.CharacterPositionMode.custom,
    column: (column * 2 + 1) / 10,
    row: (row * 2 + 1) / 10,
  );

  /// Old AI-layout snapshots may have no centers. Resolve those with the same
  /// defaults as the editor; malformed explicit manual centers still fail.
  static ImageParams effectiveParams(ImageParams params) {
    if (params.characters.isEmpty) return params;
    return params.copyWith(
      useCoords: true,
      characters: [
        for (var i = 0; i < params.characters.length; i++)
          _withCenter(params, i),
      ],
    );
  }

  static CharacterPrompt _withCenter(ImageParams params, int index) {
    final character = params.characters[index];
    final center = CharacterCenterResolver.resolve(
      character,
      index: index,
      total: params.characters.length,
      useCoords: params.useCoords,
    );
    final snapped = _snap(
      ui.CharacterPosition(column: center.x, row: center.y),
    );
    return character.copyWith(
      positionX: snapped.column,
      positionY: snapped.row,
    );
  }
}
