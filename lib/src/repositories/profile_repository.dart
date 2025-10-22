import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import '../services/local_photo_store.dart';
import '../services/preferences_service.dart';

class ProfileRepository extends ChangeNotifier {
  final PreferencesService _preferencesService;
  final LocalPhotoStore _localPhotoStore;
  String? _userPhotoPath;
  String? _userName;
  String? _userEmail;

  ProfileRepository(this._preferencesService, this._localPhotoStore) {
    _loadUserData();
  }

  String? get userPhotoPath => _userPhotoPath;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  Future<void> _loadUserData() async {
    _userPhotoPath = _preferencesService.getUserPhotoPath();
    _userName = _preferencesService.getUserName();
    _userEmail = _preferencesService.getUserEmail();
    notifyListeners();
  }

  Future<void> setPhoto(XFile photo) async {
    try {
      final savedPhotoPath = await _localPhotoStore.savePhoto(photo);
      await _preferencesService.setUserPhotoPath(savedPhotoPath);
      _userPhotoPath = savedPhotoPath;
      notifyListeners();
    } catch (e) {
      await removePhoto(); // Em caso de erro, limpa o estado
      rethrow;
    }
  }

  Future<void> removePhoto() async {
    await _localPhotoStore.deletePhoto();
    await _preferencesService.setUserPhotoPath(null);
    _userPhotoPath = null;
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    await _preferencesService.setUserName(name);
    _userName = name;
    notifyListeners();
  }

  Future<void> setUserEmail(String email) async {
    await _preferencesService.setUserEmail(email);
    _userEmail = email;
    notifyListeners();
  }

  String getInitials() {
    if (_userName == null || _userName!.isEmpty) return '';
    
    final nameParts = _userName!.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    }
    return nameParts.first[0].toUpperCase();
  }
}