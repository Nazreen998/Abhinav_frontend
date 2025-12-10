import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class PendingShopService {
  static const String base = "https://abhinav-backend-4.onrender.com/api";

  Map<String, String> get headers => {
        "Content-Type": "application/json",
        if (AuthService.token != null)
          "Authorization": "Bearer ${AuthService.token}",
      };

  // -------------------------------------------------------
  // GET ALL PENDING SHOPS
  // -------------------------------------------------------
  Future<List<dynamic>> getPendingShops() async {

    final url = Uri.parse("$base/pending/all");

    final res = await http.get(url, headers: headers);

    if (res.statusCode != 200) return [];

    final data = jsonDecode(res.body);

    if (data["status"] == "success") {
      return data["shops"] ?? [];
    }

    return [];
  }

  // -------------------------------------------------------
  // APPROVE SHOP
  // -------------------------------------------------------
  Future<bool> approveShop(String id) async {
    final url = Uri.parse("$base/pending/approve/$id");

    final res = await http.post(url, headers: headers);

    if (res.statusCode != 200) return false;

    final data = jsonDecode(res.body);
    return data["status"] == "success";
  }

  // -------------------------------------------------------
  // REJECT SHOP
  // -------------------------------------------------------
  Future<bool> rejectShop(String id) async {
    final url = Uri.parse("$base/pending/reject/$id");

    final res = await http.delete(url, headers: headers);

    if (res.statusCode != 200) return false;

    final data = jsonDecode(res.body);
    return data["status"] == "success";
  }
}
