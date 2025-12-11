import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import 'auth_service.dart';

class UserService {
  // ✔ CorrectBASE URL (DO NOT ADD /all HERE)
  static const String baseUrl =
      "https://abhinav-backend-5.onrender.com/api/user";

  // -------------------------------------------------------
  // HEADERS
  // -------------------------------------------------------
  Map<String, String> get headers => {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${AuthService.token ?? ""}",
      };

  // -------------------------------------------------------
  // GET ALL USERS  ✔ FIXED ROUTE: /api/user/all
  // -------------------------------------------------------
  Future<List<UserModel>> getUsers() async {
    try {
      final url = Uri.parse("$baseUrl/all");

      final res = await http.get(url, headers: headers);

      print("USER LIST RESPONSE = ${res.body}");

      final data = jsonDecode(res.body);

      if (data is List) {
        // backend gives array
        return data.map<UserModel>((u) => UserModel.fromJson(u)).toList();
      }

      if (data["status"] != "success") return [];

      final List list = data["users"] ?? [];
      return list.map((u) => UserModel.fromJson(u)).toList();

    } catch (e) {
      print("GET USERS ERROR: $e");
      return [];
    }
  }

  // -------------------------------------------------------
  // ADD USER ✔ FIXED ROUTE: /api/user/addUser
  // -------------------------------------------------------
  Future<bool> addUser(UserModel user) async {
    try {
      final url = Uri.parse("$baseUrl/addUser");

      final res = await http.post(
        url,
        headers: headers,
        body: jsonEncode(user.toJson()),
      );

      print("ADD USER RESPONSE: ${res.body}");

      if (res.statusCode != 200) return false;

      final data = jsonDecode(res.body);
      return data["status"] == "success";
    } catch (e) {
      print("ADD USER ERROR: $e");
      return false;
    }
  }

  // -------------------------------------------------------
  // UPDATE USER ✔ FIXED ROUTE: /api/user/edit/:id
  // -------------------------------------------------------
  Future<bool> updateUser(UserModel user) async {
    try {
      final url = Uri.parse("$baseUrl/edit/${user.id}");

      final res = await http.put(
        url,
        headers: headers,
        body: jsonEncode({
          "name": user.name,
          "mobile": user.mobile,
          "role": user.role,
          "segment": user.segment,
        }),
      );

      print("UPDATE USER RESPONSE: ${res.body}");

      if (res.statusCode != 200) return false;

      final data = jsonDecode(res.body);
      return data["status"] == "success";
    } catch (e) {
      print("UPDATE USER ERROR: $e");
      return false;
    }
  }

  // -------------------------------------------------------
  // DELETE USER ✔ FIXED ROUTE: /api/user/delete/:id
  // -------------------------------------------------------
  Future<bool> deleteUser(String id) async {
    try {
      final url = Uri.parse("$baseUrl/delete/$id");

      final res = await http.delete(url, headers: headers);

      print("DELETE USER RESPONSE: ${res.body}");

      if (res.statusCode != 200) return false;

      final data = jsonDecode(res.body);
      return data["status"] == "success";
    } catch (e) {
      print("DELETE USER ERROR: $e");
      return false;
    }
  }
}
