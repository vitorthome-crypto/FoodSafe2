import 'package:cross_file/cross_file.dart';
import 'local_photo_store_io.dart' if (dart.library.html) 'local_photo_store_web.dart' as platform;

/// Interface for photo storage implementations
abstract class LocalPhotoStore {
  /// Create a new instance
  const LocalPhotoStore();

  /// Create a new platform-specific instance
  factory LocalPhotoStore.create() => platform.createPlatformPhotoStore();

  /// Saves a photo and returns its path
  Future<String> savePhoto(XFile photo);

  /// Deletes the stored photo
  Future<void> deletePhoto();

  /// Gets the stored photo
  /// Returns File for IO platform and Uint8List for Web
  Future<dynamic> getPhoto();
}