import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();
  Future<String?> getCachedToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _userKey = 'cached_user';

  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final jsonString = sharedPreferences.getString(_userKey);
    if (jsonString == null) return null;
    return UserModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferences.clear();
  }

  @override
  Future<String?> getCachedToken() async {
    final user = await getCachedUser();
    return user?.token.isEmpty == true ? null : user?.token;
  }
}
