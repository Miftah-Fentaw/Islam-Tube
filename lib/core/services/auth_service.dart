import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String name;
  final String email;
  final String password;

  User({required this.name, required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json['name'],
    email: json['email'],
    password: json['password'],
  );
}

class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';

  Future<bool> signUp(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];

    // Check if user already exists
    final users = usersJson.map((u) => User.fromJson(jsonDecode(u))).toList();
    if (users.any((u) => u.email == email)) {
      return false;
    }

    final newUser = User(name: name, email: email, password: password);
    usersJson.add(jsonEncode(newUser.toJson()));
    await prefs.setStringList(_usersKey, usersJson);

    // Auto-login after signup
    await prefs.setString(_currentUserKey, jsonEncode(newUser.toJson()));
    return true;
  }

  Future<bool> signIn(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];

    for (var userJson in usersJson) {
      final user = User.fromJson(jsonDecode(userJson));
      if (user.email == email && user.password == password) {
        await prefs.setString(_currentUserKey, userJson);
        return true;
      }
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_currentUserKey);
  }
}
