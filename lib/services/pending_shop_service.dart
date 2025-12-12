import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class PendingShopService {
  static const String base =
      "https://abhinav-backend-5.onrender.com/api";

  Map<String, String> get headers => {
        "Content-Type": "application/json",
        if (AuthService.token != null)
          "Authorization": "Bearer ${AuthService.token}",
      };

  // -------------------------------------------------------
  // GET PENDING SHOPS (MASTER / MANAGER)
  // -------------------------------------------------------
  Future<List<dynamic>> getPendingShops() async {
    final url = Uri.parse("$base/pending/list");

    final res = await http.get(url, headers: headers);

    if (res.statusCode != 200) {
      return [];
    }

    final data = jsonDecode(res.body);

    if (data["success"] == true) {
      return data["data"] ?? [];
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
    return data["success"] == true;
  }

  // -------------------------------------------------------
  // REJECT SHOP
  // -------------------------------------------------------
  Future<bool> rejectShop(String id) async {
    final url = Uri.parse("$base/pending/reject/$id");

    final res = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        "reason": "Rejected by manager",
      }),
    );

    if (res.statusCode != 200) return false;

    final data = jsonDecode(res.body);
    return data["success"] == true;
  }
}
