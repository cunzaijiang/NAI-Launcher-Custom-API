import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/nai_api_endpoint_service.dart';
import '../../../core/utils/chat_character_position.dart';
import '../../../data/models/character/character_prompt.dart';
import '../../../l10n/app_localizations.dart';
import '../../adaptive/adaptive_presenter.dart';
import '../../adaptive/content_sized_adaptive_form.dart';
import '../../providers/character_prompt_provider.dart';

/// Per-character Chat placement. Native NovelAI keeps its continuous canvas.
class ChatCharacterPositionButton extends ConsumerWidget {
  const ChatCharacterPositionButton({super.key, required this.characterId});

  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(naiApiEndpointConfigProvider).isOpenAiCompatible) {
      return const SizedBox.shrink();
    }
    final config = ref.watch(effectiveCharacterPromptConfigProvider);
    final character = config.findCharacterById(characterId);
    if (character == null) return const SizedBox.shrink();
    final position = config.resolvePosition(character);
    final label = ChatCharacterPosition.grid(position.column, position.row);
    final l10n = AppLocalizations.of(context)!;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton.icon(
        key: ValueKey('character-position-$characterId'),
        icon: const Icon(Icons.grid_on, size: 18),
        label: Text('${l10n.characterCanvas_title}: $label'),
        onPressed: () async {
          final selected = await AdaptivePresenter.showForm<CharacterPosition>(
            context: context,
            title: '${character.name} · ${l10n.characterCanvas_title}',
            dialogWidth: 400,
            headerScrollsWithContent: true,
            builder: (panelContext, controller) => ContentSizedAdaptiveForm(
              scrollController: controller,
              content: [
                ChatCharacterPositionGrid(
                  selected: label,
                  onSelected: (position) =>
                      Navigator.of(panelContext).pop(position),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () => Navigator.of(panelContext).pop(),
                    child: Text(l10n.common_cancel),
                  ),
                ),
              ],
            ),
          );
          if (!context.mounted || selected == null) return;
          if (!ref.read(naiApiEndpointConfigProvider).isOpenAiCompatible) {
            return;
          }
          // Re-read after the modal: never overwrite edits made while it was open.
          final current = ref
              .read(characterPromptNotifierProvider)
              .findCharacterById(characterId);
          if (current == null) return;
          ref
              .read(characterPromptNotifierProvider.notifier)
              .updateCharacter(
                current.copyWith(
                  positionMode: CharacterPositionMode.custom,
                  customPosition: selected,
                ),
              );
        },
      ),
    );
  }
}

/// API cells use centers 0.1/0.3/0.5/0.7/0.9, not the optional composition
/// guide's 10×10 lines or the legacy percentage-to-grid approximation.
class ChatCharacterPositionGrid extends StatelessWidget {
  const ChatCharacterPositionGrid({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<CharacterPosition> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = math.max(
          44.0,
          MediaQuery.textScalerOf(context).scale(14) * 1.8,
        );
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: math.max(constraints.maxWidth, cellWidth * 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var row = 0; row < 5; row++)
                  Row(
                    children: [
                      for (var column = 0; column < 5; column++)
                        Expanded(child: _cell(context, column, row)),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _cell(BuildContext context, int column, int row) {
    final label = '${String.fromCharCode(65 + column)}${row + 1}';
    final isSelected = selected == label;
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      selected: isSelected,
      child: TextButton(
        key: ValueKey('character-position-cell-$label'),
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          backgroundColor: isSelected
              ? colors.primaryContainer
              : Colors.transparent,
          foregroundColor: isSelected
              ? colors.onPrimaryContainer
              : colors.onSurfaceVariant,
        ),
        onPressed: () => onSelected(ChatCharacterPosition.cell(column, row)),
        child: Text(label),
      ),
    );
  }
}
