import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _userPhotoPathKey = 'userPhotoPath';
  static const String _userPhotoUpdatedAtKey = 'userPhotoUpdatedAt';
  static const String _userNameKey = 'userName';
  static const String _userEmailKey = 'userEmail';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  Future<void> setUserPhotoPath(String? path) async {
    if (path != null) {
      await _prefs.setString(_userPhotoPathKey, path);
      await _prefs.setInt(_userPhotoUpdatedAtKey, DateTime.now().millisecondsSinceEpoch);
    } else {
      await _prefs.remove(_userPhotoPathKey);
      await _prefs.remove(_userPhotoUpdatedAtKey);
    }
  }

  String? getUserPhotoPath() => _prefs.getString(_userPhotoPathKey);
  
  int? getUserPhotoUpdatedAt() => _prefs.getInt(_userPhotoUpdatedAtKey);

  Future<void> setUserName(String name) async {
    await _prefs.setString(_userNameKey, name);
  }

  String? getUserName() => _prefs.getString(_userNameKey);

  Future<void> setUserEmail(String email) async {
    await _prefs.setString(_userEmailKey, email);
  }

  String? getUserEmail() => _prefs.getString(_userEmailKey);
}