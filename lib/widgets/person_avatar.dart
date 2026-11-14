import 'package:flutter/material.dart';
import '../services/image_service.dart';

/// A round avatar showing the person's photo if they have one, otherwise
/// their emoji.
class PersonAvatar extends StatelessWidget {
  final String? imageName;
  final String? emoji;
  final double size;
  final Color background;
  final Color? borderColor;

  const PersonAvatar({
    super.key,
    required this.imageName,
    required this.emoji,
    required this.size,
    required this.background,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final file = ImageService.fileFor(imageName);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 2.5)
            : null,
        image: file != null
            ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
            : null,
      ),
      child: file != null
          ? null
          : Center(
              child: Text(
                emoji ?? '🎁',
                style: TextStyle(fontSize: size * 0.52),
              ),
            ),
    );
  }
}

/// The person's background photo with a darkening gradient so white text on
/// top stays readable. Returns null when there is no background.
Widget? personBackground(String? imageName) {
  final file = ImageService.fileFor(imageName);
  if (file == null) return null;
  return Stack(
    fit: StackFit.expand,
    children: [
      Image.file(file, fit: BoxFit.cover),
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.15),
              Colors.black.withValues(alpha: 0.6),
            ],
          ),
        ),
      ),
    ],
  );
}
