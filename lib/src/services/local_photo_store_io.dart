import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cross_file/cross_file.dart';

import 'local_photo_store.dart';

class LocalPhotoStoreIO extends LocalPhotoStore {
  static const String _avatarFileName = 'avatar.webp';
  static const int _targetSize = 200 * 1024; // 200KB
  static const int _maxDimension = 512;

  /// Optional provider to obtain the application documents directory.
  /// Useful for testing to inject a temporary directory.
  final Future<Directory> Function()? documentsDirectoryProvider;
  /// Optional compression function used to compress and remove EXIF.
  /// Signature matches: (inputFile, targetPath) -> Future<File?>
  final Future<File?> Function(File, String)? compressAndGetFileFn;

  LocalPhotoStoreIO({this.documentsDirectoryProvider, this.compressAndGetFileFn});

  @override
  Future<String> savePhoto(XFile photo) async {
    final file = File(photo.path);
  final directory = documentsDirectoryProvider != null
    ? await documentsDirectoryProvider!()
    : await getApplicationDocumentsDirectory();
    final targetPath = path.join(directory.path, _avatarFileName);
    
    final compressedFile = await _compressAndRemoveExif(file, targetPath);
    return compressedFile.path;
  }

  Future<File> _compressAndRemoveExif(File file, String targetPath) async {
    final result = compressAndGetFileFn != null
        ? await compressAndGetFileFn!(file, targetPath)
        : await FlutterImageCompress.compressAndGetFile(
            file.path,
            targetPath,
            format: CompressFormat.webp,
            quality: 80,
            minWidth: _maxDimension,
            minHeight: _maxDimension,
            keepExif: false, // Remove EXIF data
          );

    if (result == null) {
      throw Exception('Falha ao comprimir a imagem');
    }

    final File resultFile = result is File ? result : File((result as File).path);
    // Verifica se o tamanho está dentro do limite
    if (await resultFile.length() > _targetSize) {
      // Se ainda estiver muito grande, tenta comprimir mais
      return _compressAndRemoveExif(resultFile, targetPath);
    }

    return resultFile;
  }

  Future<void> deletePhoto() async {
  final directory = documentsDirectoryProvider != null
    ? await documentsDirectoryProvider!()
    : await getApplicationDocumentsDirectory();
    final filePath = path.join(directory.path, _avatarFileName);
    final file = File(filePath);
    
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File?> getPhoto() async {
  final directory = documentsDirectoryProvider != null
    ? await documentsDirectoryProvider!()
    : await getApplicationDocumentsDirectory();
    final filePath = path.join(directory.path, _avatarFileName);
    final file = File(filePath);
    
    if (await file.exists()) {
      return file;
    }
    return null;
  }
}

/// Creates platform-specific implementation
LocalPhotoStore createPlatformPhotoStore() => LocalPhotoStoreIO();