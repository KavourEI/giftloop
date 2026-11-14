import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Stores person photos (avatars and card backgrounds) in the app's documents
/// folder. Only the file name is kept on the person, because the absolute path
/// of the app container changes between installs and updates on iOS.
class ImageService {
  static String? _dir;
  static final _picker = ImagePicker();

  static Future<void> init() async {
    if (kIsWeb) return;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/person_images');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    _dir = dir.path;
  }

  static File? fileFor(String? name) {
    if (name == null || _dir == null) return null;
    final f = File('$_dir/$name');
    return f.existsSync() ? f : null;
  }

  /// Lets the user pick a photo and copies it into app storage. Returns the
  /// stored file name, or null if cancelled.
  static Future<String?> pick(ImageSource source, {double maxSize = 1200}) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: maxSize,
      maxHeight: maxSize,
      imageQuality: 85,
    );
    if (picked == null) return null;
    return saveBytes(await picked.readAsBytes());
  }

  static Future<String?> saveBytes(Uint8List bytes) async {
    if (_dir == null) return null;
    final name = '${const Uuid().v4()}.jpg';
    await File('$_dir/$name').writeAsBytes(bytes, flush: true);
    return name;
  }

  static Future<void> delete(String? name) async {
    final f = fileFor(name);
    if (f != null) {
      try {
        await f.delete();
      } catch (_) {}
    }
  }
}
