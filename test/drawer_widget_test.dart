import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodsafe/src/widgets/custom_drawer.dart';
import 'package:foodsafe/src/repositories/profile_repository.dart';
import 'package:foodsafe/src/services/preferences_service.dart';
import 'package:foodsafe/src/services/local_photo_store.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProfileRepository profileRepository;
  late PreferencesService preferencesService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    preferencesService = PreferencesService(prefs);
    profileRepository = ProfileRepository(
      preferencesService,
      LocalPhotoStore.create(),
    );
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

  group('CustomDrawer Widget Tests', () {
    testWidgets('Exibe iniciais quando não há foto', (tester) async {
      await profileRepository.setUserName('John Doe');
      await tester.pumpWidget(createDrawerWidget());

      expect(find.text('JD'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is CircleAvatar && widget.backgroundImage == null,
        ),
        findsOneWidget,
      );
    });

    testWidgets('Bottom sheet mostra opções corretas sem foto', (tester) async {
      await tester.pumpWidget(createDrawerWidget());
      
      // Toca no avatar para abrir o bottom sheet (InkWell dentro do DrawerHeader)
      await tester.tap(
        find.descendant(of: find.byType(DrawerHeader), matching: find.byType(InkWell)).first,
      );
      await tester.pumpAndSettle();

      // Verifica as opções disponíveis
      expect(find.text('Tirar foto'), findsOneWidget);
      expect(find.text('Escolher da galeria'), findsOneWidget);
      expect(find.text('Remover foto'), findsNothing);
  // Mensagem de privacidade (uso texto parcial para robustez)
  expect(find.textContaining('Sua foto fica apenas neste dispositivo'), findsOneWidget);
    });

    testWidgets('Avatar tem tamanho mínimo para acessibilidade', (tester) async {
      await tester.pumpWidget(createDrawerWidget());
      
      final avatarFinder = find.byType(CircleAvatar);
      final Size avatarSize = tester.getSize(avatarFinder);
      
      expect(avatarSize.width, greaterThanOrEqualTo(48.0));
      expect(avatarSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('Avatar tem rótulos de acessibilidade e é clicável', (tester) async {
      await profileRepository.setUserName('John Doe');
      await tester.pumpWidget(createDrawerWidget());
      
      // Verifica se o InkWell está presente e é clicável
      final inkWellFinder = find.byType(InkWell).first;
      final inkWell = tester.widget<InkWell>(inkWellFinder);
      expect(inkWell.onTap, isNotNull);
      
      // Verifica se o CircleAvatar está presente
      expect(find.byType(CircleAvatar), findsOneWidget);
      
      // Verifica se as iniciais são exibidas
      expect(find.text('JD'), findsOneWidget);
      
      // Verifica o tamanho do avatar para acessibilidade
      final avatarFinder = find.byType(CircleAvatar);
      final Size avatarSize = tester.getSize(avatarFinder);
      expect(avatarSize.width, greaterThanOrEqualTo(48.0));
      expect(avatarSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('Mede tempo de carregamento do Drawer', (tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(createDrawerWidget());
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Verifica se o tempo de carregamento é menor que 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100),
          reason: 'Drawer deve carregar em menos de 100ms');
    });

    testWidgets('Bottom sheet mostra opções corretas', (tester) async {
      await tester.pumpWidget(createDrawerWidget());
      
      // Abre o bottom sheet
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();
      
      // Verifica se as opções estão presentes
      expect(find.text('Tirar foto'), findsOneWidget);
      expect(find.text('Escolher da galeria'), findsOneWidget);
  expect(find.textContaining('Sua foto fica apenas neste dispositivo'), findsOneWidget);
      
      // Verifica se o botão de remover não está presente quando não há foto
      expect(find.text('Remover foto'), findsNothing);
    });
  });
}