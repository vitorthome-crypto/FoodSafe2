import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/profile_repository.dart';
import '../services/image_picker_service.dart';
import 'dart:io';
import 'package:cross_file/cross_file.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<ProfileRepository>(
        builder: (context, profileRepository, _) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildDrawerHeader(context, profileRepository),
              _buildDrawerItems(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, ProfileRepository profileRepository) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: 'Foto do perfil',
            hint: profileRepository.userPhotoPath == null 
              ? 'Toque para adicionar uma foto' 
              : 'Toque para alterar sua foto',
            child: InkWell(
              onTap: () => _showPhotoOptions(context),
              child: _buildAvatar(context, profileRepository),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profileRepository.userName ?? 'Usuário',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          Text(
            profileRepository.userEmail ?? 'email@exemplo.com',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, ProfileRepository profileRepository) {
    final photoPath = profileRepository.userPhotoPath;
    final size = 72.0; // Tamanho que garante área clicável ≥48dp
    final initials = profileRepository.getInitials();
    final userName = profileRepository.userName ?? 'Usuário';

    return Semantics(
      button: true,
      enabled: true,
      label: photoPath != null 
          ? 'Foto de perfil de $userName'
          : 'Avatar com iniciais $initials',
      hint: photoPath != null
          ? 'Toque duas vezes para alterar sua foto'
          : 'Toque duas vezes para adicionar uma foto',
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: size / 2,
            backgroundColor: Colors.grey[300],
            backgroundImage: photoPath != null
                ? Image.file(
                    File(photoPath),
                    cacheWidth: 256,
                    cacheHeight: 256,
                    semanticLabel: 'Foto de perfil',
                  ).image
                : null,
            child: photoPath == null
                ? Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // Melhor contraste
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItems(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Início'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        // Adicione mais itens do menu aqui
      ],
    );
  }

  Future<void> _handleImageSelection(BuildContext context, File? image) async {
    if (image == null) return;

    try {
      final profileRepository = context.read<ProfileRepository>();
      await profileRepository.setPhoto(XFile(image.path));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto atualizada com sucesso')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao processar a imagem. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPhotoOptions(BuildContext context) {
    final profileRepository = context.read<ProfileRepository>();
    final hasPhoto = profileRepository.userPhotoPath != null;
    final imagePicker = ImagePickerService();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Semantics(
            scopesRoute: true,
            explicitChildNodes: true,
            label: 'Opções de foto do perfil',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (!hasPhoto)
                  Semantics(
                    container: true,
                    liveRegion: true,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Sua foto fica apenas neste dispositivo. '
                        'Você pode remover quando quiser.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Tirar foto'),
                  onTap: () async {
                    Navigator.pop(context);
                    final image = await imagePicker.pickImageFromCamera();
                    if (context.mounted) {
                      await _handleImageSelection(context, image);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Escolher da galeria'),
                  onTap: () async {
                    Navigator.pop(context);
                    final image = await imagePicker.pickImageFromGallery();
                    if (context.mounted) {
                      await _handleImageSelection(context, image);
                    }
                  },
                ),
                if (hasPhoto)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Remover foto'),
                    textColor: Colors.red,
                    onTap: () async {
                      Navigator.pop(context);
                      await profileRepository.removePhoto();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Foto removida com sucesso'),
                          ),
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}