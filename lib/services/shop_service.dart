import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shop_model.dart';
import '../services/auth_service.dart';

class ShopService {
  // ✔ FIXED BACKEND URL
  static const String base =
      "https://abhinav-backend-5.onrender.com/api";

  String get shopBaseUrl => "$base/shop";
  String get pendingBaseUrl => "$base/pending";

  // --------------------------------------------------------
  // GET ALL SHOPS
  // --------------------------------------------------------
  Future<List<ShopModel>> getShops() async {
    // Load token if needed
    if (AuthService.token == null) {
      await AuthService.init();
    }

    final res = await http.get(
      Uri.parse("$shopBaseUrl"),
      headers: {
        "Authorization": "Bearer ${AuthService.token ?? ''}",
      },
    );

    if (res.statusCode != 200) {
      print("❌ SHOP ERROR: ${res.body}");
      return [];
    }

    final body = jsonDecode(res.body);
    final List shops = body["shops"] ?? [];

    return shops.map((e) => ShopModel.fromJson(e)).toList();
  }

  // --------------------------------------------------------
  // ADD PENDING SHOP
  // --------------------------------------------------------
  Future<bool> addPendingShop({
    required String name,
    required String address,
    required double lat,
    required double lng,
  }) async {
    final payload = {
      "shop_name": name,
      "address": address,
      "lat": lat,
      "lng": lng,
      "segment": AuthService.currentUser?["segment"] ?? "all",
      "created_by": AuthService.currentUser?["user_id"] ?? "",
    };

    final res = await http.post(
      Uri.parse("$pendingBaseUrl/add"),
      headers: {
        "Authorization": "Bearer ${AuthService.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    return res.statusCode == 200;
  }

  // --------------------------------------------------------
  // APPROVE PENDING SHOP
  // --------------------------------------------------------
  Future<bool> approveShop(String mongoId) async {
    final res = await http.post(
      Uri.parse("$pendingBaseUrl/approve/$mongoId"),
      headers: {"Authorization": "Bearer ${AuthService.token}"},
    );

    return res.statusCode == 200;
  }
  // --------------------------------------------------------
// DELETE SHOP
// --------------------------------------------------------
Future<bool> deleteShop(String shopId) async {
  final res = await http.delete(
    Uri.parse("$shopBaseUrl/delete/$shopId"),
    headers: {
      "Authorization": "Bearer ${AuthService.token}",
    },
  );

  return res.statusCode == 200;
}
// --------------------------------------------------------
// UPDATE SHOP
// --------------------------------------------------------
Future<bool> updateShop(Map data) async {
  final res = await http.put(
    Uri.parse("$shopBaseUrl/update/${data["shop_id"]}"),
    headers: {
      "Authorization": "Bearer ${AuthService.token}",
      "Content-Type": "application/json",
    },
    body: jsonEncode(data),
  );

  return res.statusCode == 200;
}

}
