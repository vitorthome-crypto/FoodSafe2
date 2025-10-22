# FoodSafe

Projeto exemplo (Flutter) — implementação MVP do requisito "Avatar com foto no Drawer".

Este repositório contém a implementação multi-plataforma (IO / Web / Windows etc.) de um drawer com avatar que suporta adicionar/alterar/remover foto do usuário, salvamento local (sistema de arquivos no IO, IndexedDB na Web), compressão das imagens e remoção de metadados EXIF conforme o PRD.

## Principais funcionalidades

- Adicionar foto via câmera ou galeria (onde suportado)
- Armazenamento local do avatar (Web: IndexedDB; IO: diretório de documentos)
- Compressão para WebP e tentativa de manter o tamanho abaixo de ~200KB

- Remoção de metadados EXIF (quando suportado pelo compressor nativo)
- Persistência de caminho/flag em `SharedPreferences`
- Acessibilidade: `Semantics`, áreas de toque >= 48dp, textos de ajuda

- Testes unitários e de widget cobrindo comportamentos principais

## Estrutura relevante

- `lib/src/services/local_photo_store.dart` — interface abstrata e fábrica condicional
- `lib/src/services/local_photo_store_io.dart` — implementação IO (arquivo)
- `lib/src/services/local_photo_store_web.dart` — implementação Web (IndexedDB)

- `lib/src/repositories/profile_repository.dart` — orquestra salvar/remover e Preferences
- `lib/src/services/preferences_service.dart` — wrapper de `SharedPreferences`
- `lib/src/widgets/custom_drawer.dart` — Drawer UI com avatar, opções e acessibilidade

- `test/` — testes unitários e widget relevantes (ex.: `local_photo_store_test.dart`)

## Como executar (desenvolvimento)

Pré-requisitos: Flutter SDK (versão compatível com o projeto), Git.

1. Instale dependências:

```powershell
flutter pub get
```

2. Executar no Chrome (web):

```powershell
flutter run -d chrome
```

3. Executar no Windows (desktop):

```powershell
flutter run -d windows
```

4. Executar no emulador Android / dispositivo:

```powershell
flutter devices; flutter run -d <deviceId>
```

Observação: em algumas máquinas pode ser necessário `flutter clean` seguido de `flutter pub get` se ocorrerem erros de build.

## Testes

Rodar todos os testes (unitários + widget):

```powershell
flutter test
```

Rodar um teste específico (exemplo):

```powershell
flutter test test/local_photo_store_test.dart -r expanded --verbose
```

Notas sobre testes:
- Código específico da Web que importa `dart:html` foi isolado via conditional imports — testes em VM não importam código Web.
- Algumas dependências nativas (ex.: compressão) são simuladas/injetadas nos testes unitários para evitar dependências de plataforma durante CI.

## Checklist de conformidade com o PRD (Avatar no Drawer)

- [x] Adicionar foto (camera/galeria) — implementado (image picker service)
- [x] Alterar foto — implementado
- [x] Remover foto — implementado

- [x] Persistência local (IO/IndexedDB) — implementado
- [x] Compressão de imagens e tentativa de manter <= ~200KB — implementado (recompressão iterativa em IO; web compressWithList)
- [x] Remoção de EXIF/GPS — implementado quando suportado pelo compressor

- [x] SharedPreferences keys para rastreamento de foto e timestamp — implementado
- [x] Acessibilidade (Semantics, hints, tamanhos de toque) — implementado na UI do drawer
- [x] Testes (unidade + widget) cobrindo fluxo principal — implementados e adaptados para ambiente de teste

- [ ] Evidências (screenshots / vídeo) — pendente (incluir antes da entrega)

## Observações de desenvolvimento e recomendações

- Nos testes unitários usamos injeção para o compressor e provider de diretório (evitar dependência de plataformas nativas em CI).
- Recomendo adicionar um limite máximo de tentativas na rotina de recompressão para evitar loops se um compressor não reduzir o arquivo.

- Para rodar testes web (ex.: `flutter test --platform chrome`) configure o ambiente com Chrome headless ou use um job separado no CI.

## Preparar entrega

Quando quiser preparar a entrega final, sugerimos:

1. Executar todos os testes localmente: `flutter test`
2. Gerar evidências: capturas de tela do Drawer antes/depois, gravação curta do fluxo de adicionar/remover foto.

3. Tag de release (ex.):

```powershell
git tag -a avatar-photo-drawer-mvp -m "MVP Avatar no Drawer"
git push origin avatar-photo-drawer-mvp
```

4. Criar PR com descrição, checklist preenchido e evidências anexadas.

## Contato / Ajuda

Se quiser que eu rode a suíte completa de testes, gere a tag ou produza as capturas de tela automaticamente, diga qual ação executar a seguir e eu prosseguirei.

---

Licença: veja o arquivo `LICENSE` no repositório.

# FoodSafe


