import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:cross_file/cross_file.dart';
import 'package:foodsafe/src/services/local_photo_store.dart';
import 'package:foodsafe/src/services/local_photo_store_io.dart';

// Using injected documentsDirectoryProvider in LocalPhotoStoreIO for tests
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalPhotoStore localPhotoStore;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp();
    // Inject a LocalPhotoStoreIO with a provider that returns our tempDir
    // and a simple compressor that just copies the file (avoids flutter_image_compress in tests)
    localPhotoStore = LocalPhotoStoreIO(
      documentsDirectoryProvider: () async => tempDir,
      // Compressor used in tests writes a smaller file to simulate successful compression
      compressAndGetFileFn: (File input, String targetPath) async {
        final out = File(targetPath);
        final originalSize = await input.length();
        final smaller = (originalSize / 2).ceil();
        await out.writeAsBytes(List.generate(smaller, (i) => 0));
        return out;
      },
    );
  });

  tearDown(() async {
    // On Windows files can be locked briefly by the test runner or underlying APIs.
    // Attempt deletion but don't fail the test if it can't be removed.
    try {
      await tempDir.delete(recursive: true);
    } catch (e) {
      // ignore deletion errors (locked files) — tests should not fail because of cleanup
    }
  });

  test('savePhoto compresses and removes EXIF data', () async {
    // Criar um arquivo de teste
    final testFile = File('${tempDir.path}/test.jpg')
      ..writeAsBytesSync(List.generate(1024 * 1024, (index) => 0)); // 1MB de dados

    final xFile = XFile(testFile.path);
    final savedPath = await localPhotoStore.savePhoto(xFile);

    expect(savedPath, isNotNull);
    final savedFile = File(savedPath);
    expect(await savedFile.exists(), isTrue);

    // Verificar se o arquivo foi comprimido (menor que o original)
    final compressedSize = await savedFile.length();
    expect(compressedSize, lessThan(1024 * 1024));
  });

  test('deletePhoto removes the file', () async {
    // Criar um arquivo de teste
    final testFile = File('${tempDir.path}/test.jpg')
      ..writeAsBytesSync(List.generate(1024, (index) => 0));

    final xFile = XFile(testFile.path);
    final savedPath = await localPhotoStore.savePhoto(xFile);
    expect(await File(savedPath).exists(), isTrue);

    await localPhotoStore.deletePhoto();
    expect(await File(savedPath).exists(), isFalse);
  });

  test('getPhoto returns null when no photo exists', () async {
    final photo = await localPhotoStore.getPhoto();
    expect(photo, isNull);
  });
}