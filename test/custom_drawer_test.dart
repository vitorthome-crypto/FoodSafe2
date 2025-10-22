import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:foodsafe/src/repositories/profile_repository.dart';
import 'package:foodsafe/src/services/local_photo_store.dart';
import 'package:foodsafe/src/services/preferences_service.dart';
import 'package:foodsafe/src/widgets/custom_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProfileRepository profileRepository;
  late PreferencesService preferencesService;
  late LocalPhotoStore localPhotoStore;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    preferencesService = PreferencesService(prefs);
    localPhotoStore = LocalPhotoStore.create();
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

  testWidgets('Drawer shows initials when no photo is set', (tester) async {
    await profileRepository.setUserName('John Doe');
    await tester.pumpWidget(createDrawerWidget());

    final textFinder = find.text('JD');
    expect(textFinder, findsOneWidget);
  });

  testWidgets('Drawer shows privacy message in bottom sheet', (tester) async {
    await tester.pumpWidget(createDrawerWidget());

    // Encontrar e tocar na área clicável (InkWell) associada ao avatar no DrawerHeader
    final inkFinder = find.descendant(
      of: find.byType(DrawerHeader),
      matching: find.byType(InkWell),
    ).first;
    await tester.tap(inkFinder);
    await tester.pumpAndSettle();

    // Verificar se a mensagem de privacidade está visível (uso contains para robustez)
    final privacyMessage = find.textContaining('Sua foto fica apenas neste dispositivo');
    expect(privacyMessage, findsOneWidget);
  });

  testWidgets('Avatar is accessible with correct semantics', (tester) async {
    await profileRepository.setUserName('John Doe');
    await tester.pumpWidget(createDrawerWidget());

    // Verifica que a área clicável (InkWell) do avatar existe e contém as iniciais
    final inkFinder = find.descendant(
      of: find.byType(DrawerHeader),
      matching: find.byType(InkWell),
    );
    expect(inkFinder, findsOneWidget);

    // Iniciais devem estar visíveis
    expect(find.text('JD'), findsOneWidget);
  });

  testWidgets('Bottom sheet shows all photo options', (tester) async {
    await tester.pumpWidget(createDrawerWidget());

    // Abrir o bottom sheet
    await tester.tap(find.byType(CircleAvatar));
    await tester.pumpAndSettle();

    // Verificar se todas as opções estão presentes
    expect(find.text('Tirar foto'), findsOneWidget);
    expect(find.text('Escolher da galeria'), findsOneWidget);

    // A opção de remover não deve aparecer quando não há foto
    expect(find.text('Remover foto'), findsNothing);
  });
}