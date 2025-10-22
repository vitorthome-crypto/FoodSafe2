import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/pages/home_page.dart';
import 'src/repositories/profile_repository.dart';
import 'src/services/local_photo_store.dart';
import 'src/services/preferences_service.dart';
import 'src/services/image_picker_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final preferencesService = PreferencesService(prefs);
  final localPhotoStore = LocalPhotoStore.create();
  final profileRepository = ProfileRepository(preferencesService, localPhotoStore);
  final imagePickerService = ImagePickerService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: profileRepository),
        Provider.value(value: imagePickerService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodSafe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}