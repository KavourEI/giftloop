import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/person.dart';
import '../utils/app_theme.dart';

const _avatarEmojis = [
  '🎁', '👨', '👩', '👦', '👧', '👴', '👵', '🧑', '👼',
  '🧒', '🧓', '🧔', '🦸', '🧙', '🧚', '🦄', '🐶', '🐱',
  '🐻', '🦊', '🐼', '🌟', '💫', '🌈', '🎉', '🎊', '🎈',
];

class AddEditPersonScreen extends StatefulWidget {
  final Person? person;

  const AddEditPersonScreen({super.key, this.person});

  @override
  State<AddEditPersonScreen> createState() => _AddEditPersonScreenState();
}

class _AddEditPersonScreenState extends State<AddEditPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  String? _birthday;
  String _selectedEmoji = '🎁';
  bool _saving = false;

  bool get _isEditing => widget.person != null;

  @override
  void initState() {
    super.initState();
    final p = widget.person;
    _nameController = TextEditingController(text: p?.name ?? '');
    _notesController = TextEditingController(text: p?.notes ?? '');
    _birthday = p?.birthday;
    _selectedEmoji = p?.avatarEmoji ?? '🎁';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    DateTime initial = DateTime.now();
    if (_birthday != null) {
      try {
        initial = DateTime.parse(_birthday!);
      } catch (_) {}
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select Birthday',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.coral,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _birthday = picked.toIso8601String().split('T').first);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final person = widget.person != null
        ? (widget.person!
          ..name = _nameController.text.trim()
          ..birthday = _birthday
          ..avatarEmoji = _selectedEmoji
          ..notes = _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim())
        : Person(
            id: const Uuid().v4(),
            name: _nameController.text.trim(),
            birthday: _birthday,
            avatarEmoji: _selectedEmoji,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

    Navigator.pop(context, person);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Person' : 'Add New Person'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              _isEditing ? 'Save' : 'Add',
              style: TextStyle(
                color: AppTheme.coral,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji Picker
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showEmojiPicker,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.coral.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(_selectedEmoji,
                              style: const TextStyle(fontSize: 52)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _showEmojiPicker,
                      icon: const Icon(Icons.edit_rounded, size: 14),
                      label: const Text('Choose avatar'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.coral,
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 24),

              _SectionLabel(label: 'Name *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Mom, Best Friend, John...',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ).animate().fadeIn(delay: 50.ms),

              const SizedBox(height: 20),
              _SectionLabel(label: 'Birthday (optional)'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickBirthday,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cake_rounded,
                          color: _birthday != null
                              ? AppTheme.coral
                              : Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _birthday != null
                              ? DateFormat('MMMM d, yyyy')
                                  .format(DateTime.parse(_birthday!))
                              : 'Select birthday',
                          style: TextStyle(
                            color: _birthday != null
                                ? AppTheme.charcoal
                                : Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (_birthday != null)
                        GestureDetector(
                          onTap: () => setState(() => _birthday = null),
                          child: Icon(Icons.clear_rounded,
                              color: Colors.grey.shade400, size: 18),
                        ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms),

              if (_birthday != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.sunflower.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.sunflower.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Text('🔔', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You\'ll get a reminder 7 days before this birthday!',
                          style: TextStyle(
                            color: const Color(0xFF5D3000),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              _SectionLabel(label: 'Notes (optional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Their interests, style, preferences...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.notes_rounded),
                  ),
                ),
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_isEditing ? '✓ Save Changes' : '+ Add Person'),
                ),
              ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose an avatar',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _avatarEmojis.map((emoji) {
                  final isSelected = emoji == _selectedEmoji;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedEmoji = emoji);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.coral.withOpacity(0.15)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.coral
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(emoji,
                            style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context)
          .textTheme
          .labelLarge
          ?.copyWith(color: Colors.grey.shade600),
    );
  }
}
