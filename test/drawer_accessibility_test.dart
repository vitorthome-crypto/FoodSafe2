import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:foodsafe/src/repositories/profile_repository.dart';
import 'package:foodsafe/src/services/local_photo_store.dart';
import 'package:foodsafe/src/services/preferences_service.dart';
import 'package:foodsafe/src/widgets/custom_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProfileRepository profileRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final preferencesService = PreferencesService(prefs);
    final localPhotoStore = LocalPhotoStore.create();
    profileRepository = ProfileRepository(preferencesService, localPhotoStore);
  });

  Widget createDrawerWidget() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider.value(
          value: profileRepository,
          child: const CustomDrawer(),
        ),
      ),
    );
  }

  testWidgets('Avatar tap area meets minimum size requirement', (tester) async {
    await tester.pumpWidget(createDrawerWidget());

    final avatarFinder = find.byType(InkWell).first;
    final avatarSize = tester.getSize(avatarFinder);

    // Verifica se o tamanho é >= 48dp em ambas as dimensões
    expect(avatarSize.width, greaterThanOrEqualTo(48.0));
    expect(avatarSize.height, greaterThanOrEqualTo(48.0));
  });

  testWidgets('Drawer header text has sufficient contrast', (tester) async {
    await profileRepository.setUserName('John Doe');
    await profileRepository.setUserEmail('john@example.com');
    await tester.pumpWidget(createDrawerWidget());

    final nameText = find.text('John Doe');
    final emailText = find.text('john@example.com');

    // Verificar se os textos são visíveis
    expect(nameText, findsOneWidget);
    expect(emailText, findsOneWidget);

    // Verificar o estilo do texto (contraste)
    final nameTextWidget = tester.widget<Text>(nameText);
    final emailTextWidget = tester.widget<Text>(emailText);

    expect(nameTextWidget.style?.color, Colors.white);
    expect(emailTextWidget.style?.color?.opacity, greaterThanOrEqualTo(0.8));
  });

  testWidgets('Bottom sheet options are properly labeled for accessibility',
      (tester) async {
    await tester.pumpWidget(createDrawerWidget());

    // Abrir o bottom sheet tocando na área clicável (InkWell) no DrawerHeader
    await tester.tap(
      find.descendant(of: find.byType(DrawerHeader), matching: find.byType(InkWell)).first,
    );
    await tester.pumpAndSettle();

  // Verifica que o container semântico do bottom sheet existe
  expect(find.bySemanticsLabel('Opções de foto do perfil'), findsOneWidget);

    // Verificar se as opções existem visivelmente
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    expect(find.byIcon(Icons.photo_library), findsOneWidget);
  });
}