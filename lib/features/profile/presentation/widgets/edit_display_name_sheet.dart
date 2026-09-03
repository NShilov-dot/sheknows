import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheknows/core/constants/profile.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// Bottom sheet with the one field a profile has: the display name. Saving
/// hands the text to [ProfileCubit.updateDisplayName] and closes; the header
/// shows the result optimistically and the page announces a rejected write.
class EditDisplayNameSheet extends StatefulWidget {
  const EditDisplayNameSheet({
    super.key,
    required this.cubit,
    required this.initialName,
  });

  final ProfileCubit cubit;
  final String? initialName;

  @override
  State<EditDisplayNameSheet> createState() => _EditDisplayNameSheetState();
}

class _EditDisplayNameSheetState extends State<EditDisplayNameSheet> {
  late final TextEditingController _name =
      TextEditingController(text: widget.initialName ?? '');

  /// Set the moment the write is dispatched so a double-tap in the same frame
  /// cannot fire it twice before the sheet finishes popping.
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (_saving) return;
    HapticFeedback.lightImpact();
    setState(() => _saving = true);
    widget.cubit.updateDisplayName(_name.text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          bottom: AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.profileEditName, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _name,
                autofocus: true,
                maxLength: kDisplayNameMaxLength,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                decoration: InputDecoration(
                  labelText: l10n.profileNameFieldLabel,
                  hintText: l10n.profileNameHint,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.check),
                label: Text(l10n.commonSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
