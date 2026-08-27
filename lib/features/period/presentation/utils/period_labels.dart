import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';

/// User-facing name for a [FlowLevel].
///
/// The history row used to render `log.flow!.name`, which returns the raw Dart
/// identifier — so the UI literally read "medium flow", lowercase mid-sentence
/// and untranslatable. Mirrors `symptom_labels.dart`; when localization lands
/// this takes an `AppLocalizations` and the call sites do not change.
String flowLevelLabel(FlowLevel level) => switch (level) {
      FlowLevel.light => 'Light',
      FlowLevel.medium => 'Medium',
      FlowLevel.heavy => 'Heavy',
    };
