import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Picks a reference image from the gallery, compresses it, stages it
/// locally. Returns the staged path so the repository can persist it and
/// the sync engine can upload it on next flush.
///
/// Gallery-only by design — the "exercise photo" is a reference image
/// (illustration, photo, diagram) the user chooses, not a camera capture.
class PhotoService {
  PhotoService();

  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndStage() async {
    final xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (xfile == null) return null;

    final compressed = await FlutterImageCompress.compressWithFile(
      xfile.path,
      minWidth: 800,
      quality: 80,
      format: CompressFormat.jpeg,
    );
    if (compressed == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final stagingDir = Directory(p.join(dir.path, 'photo_staging'));
    if (!stagingDir.existsSync()) {
      await stagingDir.create(recursive: true);
    }
    final filename = '${DateTime.now().microsecondsSinceEpoch}.jpg';
    final stagedPath = p.join(stagingDir.path, filename);
    await File(stagedPath).writeAsBytes(compressed);
    return stagedPath;
  }

  Future<void> deleteStaged(String localPath) async {
    final f = File(localPath);
    if (f.existsSync()) {
      await f.delete();
    }
  }
}
