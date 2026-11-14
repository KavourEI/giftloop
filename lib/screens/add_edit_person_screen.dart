import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../l10n/strings.dart';
import '../models/birthday.dart';
import '../models/person.dart';
import '../services/image_service.dart';
import '../utils/app_theme.dart';
import '../widgets/birthday_picker.dart';
import '../widgets/person_avatar.dart';

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
  Birthday? _birthday;
  String _selectedEmoji = '🎁';
  String? _avatarImage;
  String? _backgroundImage;
  bool _saved = false;

  /// Photos picked during this edit. Any not kept are deleted when leaving.
  final _pickedImages = <String>{};

  bool get _isEditing => widget.person != null;

  @override
  void initState() {
    super.initState();
    final p = widget.person;
    _nameController = TextEditingController(text: p?.name ?? '');
    _notesController = TextEditingController(text: p?.notes ?? '');
    _birthday = p?.birthdayInfo;
    _selectedEmoji = p?.avatarEmoji ?? '🎁';
    _avatarImage = p?.avatarImage;
    _backgroundImage = p?.backgroundImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    // Clean up photos the user picked but didn't keep (or cancelled).
    final keep = _saved ? {_avatarImage, _backgroundImage} : <String?>{};
    for (final name in _pickedImages) {
      if (!keep.contains(name)) ImageService.delete(name);
    }
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final picked = await showBirthdayPicker(context, initial: _birthday);
    if (picked != null) setState(() => _birthday = picked);
  }

  Future<String?> _pickPhoto(ImageSource source, {double maxSize = 1200}) async {
    try {
      final name = await ImageService.pick(source, maxSize: maxSize);
      if (name != null) _pickedImages.add(name);
      return name;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(S.of(context).photoError)));
      }
      return null;
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _saved = true;
    final notes = _notesController.text.trim();

    final old = widget.person;
    if (old != null) {
      // Delete the previous photos if they were replaced or removed.
      if (old.avatarImage != _avatarImage) ImageService.delete(old.avatarImage);
      if (old.backgroundImage != _backgroundImage) {
        ImageService.delete(old.backgroundImage);
      }
    }

    final person = old != null
        ? (old
          ..name = _nameController.text.trim()
          ..birthday = _birthday?.encode()
          ..avatarEmoji = _selectedEmoji
          ..avatarImage = _avatarImage
          ..backgroundImage = _backgroundImage
          ..notes = notes.isEmpty ? null : notes)
        : Person(
            id: const Uuid().v4(),
            name: _nameController.text.trim(),
            birthday: _birthday?.encode(),
            avatarEmoji: _selectedEmoji,
            avatarImage: _avatarImage,
            backgroundImage: _backgroundImage,
            notes: notes.isEmpty ? null : notes,
          );

    Navigator.pop(context, person);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? s.editPerson : s.addNewPerson),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              _isEditing ? s.save : s.add,
              style: const TextStyle(
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
              // Avatar
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showAvatarPicker,
                      child: Stack(
                        children: [
                          PersonAvatar(
                            imageName: _avatarImage,
                            emoji: _selectedEmoji,
                            size: 100,
                            background: AppTheme.coral.withValues(alpha: 0.1),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppTheme.coral,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_rounded,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _showAvatarPicker,
                      icon: const Icon(Icons.edit_rounded, size: 14),
                      label: Text(s.choosePhotoOrEmoji),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.coral,
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 16),

              _SectionLabel(label: s.nameRequiredLabel),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: s.nameHint,
                  prefixIcon: const Icon(Icons.person_rounded),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? s.nameRequired : null,
              ).animate().fadeIn(delay: 50.ms),

              const SizedBox(height: 20),
              _SectionLabel(label: s.birthdayOptional),
              const SizedBox(height: 8),
              _BirthdayField(
                birthday: _birthday,
                onTap: _pickBirthday,
                onClear: () => setState(() => _birthday = null),
              ).animate().fadeIn(delay: 100.ms),

              if (_birthday != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.sunflower.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.sunflower.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Text('🔔', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s.reminderInfo,
                          style: const TextStyle(
                            color: Color(0xFF5D3000),
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
              _SectionLabel(label: s.cardBackground),
              const SizedBox(height: 8),
              _BackgroundField(
                imageName: _backgroundImage,
                onPick: () async {
                  final name =
                      await _pickPhoto(ImageSource.gallery, maxSize: 1600);
                  if (name != null) setState(() => _backgroundImage = name);
                },
                onRemove: () => setState(() => _backgroundImage = null),
              ).animate().fadeIn(delay: 125.ms),

              const SizedBox(height: 20),
              _SectionLabel(label: s.notesOptional),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: s.notesHint,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.notes_rounded),
                  ),
                ),
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(_isEditing ? s.saveChanges : s.addPersonButton),
                ),
              ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms),
            ],
          ),
        ),
      ),
    );
  }

  void _showAvatarPicker() {
    final s = S.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        Future<void> pick(ImageSource source) async {
          Navigator.pop(sheetContext);
          final name = await _pickPhoto(source, maxSize: 600);
          if (name != null) setState(() => _avatarImage = name);
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.avatar,
                    style: Theme.of(sheetContext).textTheme.titleLarge),
                const SizedBox(height: 12),
                _SheetAction(
                  icon: Icons.photo_library_rounded,
                  label: s.chooseFromPhotos,
                  onTap: () => pick(ImageSource.gallery),
                ),
                _SheetAction(
                  icon: Icons.photo_camera_rounded,
                  label: s.takePhoto,
                  onTap: () => pick(ImageSource.camera),
                ),
                if (_avatarImage != null)
                  _SheetAction(
                    icon: Icons.delete_outline_rounded,
                    label: s.removePhoto,
                    color: Colors.red.shade400,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      setState(() => _avatarImage = null);
                    },
                  ),
                const SizedBox(height: 12),
                Text(s.chooseEmoji,
                    style: Theme.of(sheetContext)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: Colors.grey.shade600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _avatarEmojis.map((emoji) {
                    final isSelected =
                        _avatarImage == null && emoji == _selectedEmoji;
                    return GestureDetector(
                      onTap: () {
                        // Choosing an emoji replaces the photo.
                        setState(() {
                          _selectedEmoji = emoji;
                          _avatarImage = null;
                        });
                        Navigator.pop(sheetContext);
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.coral.withValues(alpha: 0.15)
                              : Colors.white,
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
          ),
        );
      },
    );
  }
}

class _BirthdayField extends StatelessWidget {
  final Birthday? birthday;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _BirthdayField(
      {required this.birthday, required this.onTap, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final b = birthday;
    final age = b?.turningAge;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.cake_rounded,
                color: b != null ? AppTheme.coral : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                b != null
                    ? '${formatBirthday(context, b)}${age != null ? ' · ${s.turnsAge(age)}' : ''}'
                    : s.selectBirthday,
                style: TextStyle(
                  color: b != null ? AppTheme.charcoal : Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (b != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.clear_rounded,
                    color: Colors.grey.shade400, size: 18),
              )
            else
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _BackgroundField extends StatelessWidget {
  final String? imageName;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _BackgroundField(
      {required this.imageName, required this.onPick, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final file = ImageService.fileFor(imageName);
    if (file == null) {
      return GestureDetector(
        onTap: onPick,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.wallpaper_rounded, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.addBackground,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(s.cardBackgroundSub,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Icon(Icons.add_photo_alternate_rounded,
                  color: Colors.grey.shade400),
            ],
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 120,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(file, fit: BoxFit.cover),
            Positioned(
              right: 8,
              bottom: 8,
              child: Row(
                children: [
                  _ImageChip(
                      icon: Icons.edit_rounded,
                      label: s.changeBackground,
                      onTap: onPick),
                  const SizedBox(width: 8),
                  _ImageChip(
                      icon: Icons.delete_outline_rounded,
                      label: s.remove,
                      onTap: onRemove),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ImageChip(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _SheetAction(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.charcoal;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: color ?? AppTheme.coral),
      title: Text(label,
          style: TextStyle(fontWeight: FontWeight.w600, color: c)),
      onTap: onTap,
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
