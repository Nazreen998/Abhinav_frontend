import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import 'auth_service.dart';

class UserService {
  static const String baseUrl =
      "https://abhinav-backend-5.onrender.com/api/users";

  Map<String, String> get headers => {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${AuthService.token ?? ""}",
      };

  // GET USERS
  Future<List<UserModel>> getUsers() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/all"),
        headers: headers,
      );

      final data = jsonDecode(res.body);
      if (data["success"] != true) return [];

      final List list = data["users"] ?? [];
      return list.map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // ADD USER
  Future<bool> addUser(UserModel user) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/addUser"),
        headers: headers,
        body: jsonEncode(user.toJson()),
      );

      final data = jsonDecode(res.body);
      return data["success"] == true;
    } catch (e) {
      return false;
    }
  }

  // UPDATE USER
  Future<bool> updateUser(UserModel user) async {
    try {
      final res = await http.put(
        Uri.parse("$baseUrl/edit/${user.id}"),
        headers: headers,
        body: jsonEncode({
          "name": user.name,
          "mobile": user.mobile,
          "role": user.role,
          "segment": user.segment,
        }),
      );

      final data = jsonDecode(res.body);
      return data["success"] == true;
    } catch (e) {
      return false;
    }
  }

  // DELETE USER
  Future<bool> deleteUser(String id) async {
    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/delete/$id"),
        headers: headers,
      );

      final data = jsonDecode(res.body);
      return data["success"] == true;
    } catch (e) {
      return false;
    }
  }
}
