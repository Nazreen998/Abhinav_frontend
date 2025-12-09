import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import 'auth_service.dart';

class UserService {
  static const String baseUrl =
      "https://abhinav-backend-4.onrender.com/api/users";

  Map<String, String> get headers => {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${AuthService.token}"
      };

  Future<List<UserModel>> getUsers() async {
    final url = Uri.parse("$baseUrl/all");

    final res = await http.get(url, headers: headers);

    if (res.statusCode != 200) return [];

    final data = jsonDecode(res.body);
    final List list = data["users"] ?? [];

    return list.map((u) => UserModel.fromJson(u)).toList();
  }

  Future<bool> addUser(UserModel user) async {
    final url = Uri.parse("$baseUrl/addUser");

    final res = await http.post(
      url,
      headers: headers,
      body: jsonEncode(user.toJson()),
    );

    print("ADD USER RESPONSE: ${res.body}");

    return res.statusCode == 200;
  }

  Future<bool> updateUser(UserModel user) async {
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

    print("UPDATE RESPONSE: ${res.body}");

    return res.statusCode == 200;
  }

  Future<bool> deleteUser(String id) async {
    final url = Uri.parse("$baseUrl/delete/$id");

    final res = await http.delete(url, headers: headers);

    print("DELETE RESPONSE: ${res.body}");

    return res.statusCode == 200;
  }
}
