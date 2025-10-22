import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cross_file/cross_file.dart';
import 'local_photo_store.dart';

class LocalPhotoStoreWeb extends LocalPhotoStore {
  static const String _avatarFileName = 'avatar.webp';
  static const int _targetSize = 200 * 1024; // 200KB
  static const int _maxDimension = 512;

  LocalPhotoStoreWeb();

  @override
  Future<String> savePhoto(XFile photo) async {
    try {
      final bytes = await photo.readAsBytes();
      final compressedBytes = await _compressAndRemoveExif(bytes);
      
      final db = await _openIndexedDB();
      final transaction = db.transaction('photos', 'readwrite');
      final objectStore = transaction.objectStore('photos');
      await objectStore.put(compressedBytes, _avatarFileName);

      return _avatarFileName;
    } catch (e) {
      print('Error saving photo: $e');
      rethrow;
    }
  }

  Future<Uint8List> _compressAndRemoveExif(Uint8List bytes) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: _maxDimension,
        minHeight: _maxDimension,
        quality: 80,
        format: CompressFormat.webp,
      );

      if (result.length > _targetSize) {
        return _compressAndRemoveExif(result);
      }

      return result;
    } catch (e) {
      print('Error compressing photo: $e');
      rethrow;
    }
  }

  Future<void> deletePhoto() async {
    try {
      final db = await _openIndexedDB();
      final transaction = db.transaction('photos', 'readwrite');
      final objectStore = transaction.objectStore('photos');
      await objectStore.delete(_avatarFileName);
    } catch (e) {
      print('Error deleting photo: $e');
      rethrow;
    }
  }

  Future<Uint8List?> getPhoto() async {
    try {
      final db = await _openIndexedDB();
      final transaction = db.transaction('photos', 'readonly');
      final objectStore = transaction.objectStore('photos');
      final result = await objectStore.get(_avatarFileName);
      return result as Uint8List?;
    } catch (e) {
      print('Error getting photo: $e');
      rethrow;
    }
  }

  Future<dynamic> _openIndexedDB() async {
    try {
      final idb = html.window.indexedDB;
      if (idb == null) throw Exception('IndexedDB not supported');
      
      return await idb.open('foodsafe_photos', version: 1, 
        onUpgradeNeeded: (event) {
          final db = event.target.result;
          if (!db.objectStoreNames!.contains('photos')) {
            db.createObjectStore('photos');
          }
        });
    } catch (e) {
      print('Error opening IndexedDB: $e');
      rethrow;
    }
  }
}

/// Creates platform-specific implementation
LocalPhotoStore createPlatformPhotoStore() => LocalPhotoStoreWeb();