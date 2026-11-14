import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../models/gift_idea.dart';
import '../services/settings_service.dart';
import '../utils/app_theme.dart';

const _categoryEmojis = [
  '🏷️', '🎲', '🧩', '🍷', '☕', '🧁', '🌱', '🐾', '📷', '🎮', '🎧', '🧴',
  '👟', '🎒', '🕯️', '🖋️', '🏋️', '🚲', '🎣', '⛺', '🧶', '🪴', '💐', '🎟️',
];

/// Asks for a new category name and emoji, saves it, and returns the stored
/// label (e.g. "🎲 Board games"), or null if cancelled.
Future<String?> showCreateCategoryDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const _CreateCategoryDialog(),
  );
}

class _CreateCategoryDialog extends StatefulWidget {
  const _CreateCategoryDialog();

  @override
  State<_CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<_CreateCategoryDialog> {
  final _controller = TextEditingController();
  String _emoji = _categoryEmojis.first;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = S.of(context);
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    final label = '$_emoji $name';
    final ok = await SettingsService.instance.addCategory(label, giftCategories);
    if (!mounted) return;
    if (!ok) {
      setState(() => _error = s.categoryExists);
      return;
    }
    Navigator.pop(context, label);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(s.newCategory),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: s.categoryName,
                hintText: s.categoryNameHint,
                errorText: _error,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_emoji, style: const TextStyle(fontSize: 20)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _categoryEmojis.map((e) {
                final selected = e == _emoji;
                return GestureDetector(
                  onTap: () => setState(() => _emoji = e),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.coral.withValues(alpha: 0.15)
                          : AppTheme.softGrey,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: selected ? AppTheme.coral : Colors.transparent,
                          width: 2),
                    ),
                    child: Center(
                        child: Text(e, style: const TextStyle(fontSize: 18))),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(s.create,
              style: const TextStyle(
                  color: AppTheme.coral, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
