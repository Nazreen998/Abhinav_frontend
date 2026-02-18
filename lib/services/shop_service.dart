// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shop_model.dart';
import '../services/auth_service.dart';

class ShopService {
  static const String base =
      "https://abhinav-backend.onrender.com/api";

  // ✅ FIXED ROUTE
 String get shopBaseUrl => "$base/shops";

  // -----------------------------
  // GET SHOPS
  // -----------------------------
  Future<List<ShopModel>> getShops() async {
    if (AuthService.token == null) {
      await AuthService.init();
    }

    final res = await http.get(
      Uri.parse(shopBaseUrl),
      headers: {
        "Authorization": "Bearer ${AuthService.token}",
      },
    );

    if (res.statusCode != 200) {
      print("❌ SHOP ERROR: ${res.body}");
      return [];
    }

    final data = jsonDecode(res.body);
    final list = data["shops"] ?? [];

    return list.map<ShopModel>((e) => ShopModel.fromJson(e)).toList();
  }
//------------Approval shop ---------
Future<bool> approveShop(String id) async {
  final res = await http.put(
    Uri.parse("$base/shops/approve/$id"),
    headers: {
      "Authorization": "Bearer ${AuthService.token}",
    },
  );

  return res.statusCode == 200;
}
  // -----------------------------
  // UPDATE SHOP
  // -----------------------------
  Future<bool> updateShop(Map data) async {
    final res = await http.put(
      Uri.parse("$base/shops/update/${data["_id"]}"),
      headers: {
        "Authorization": "Bearer ${AuthService.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
  "shop_name": data["shop_name"],
  "address": data["address"],
  "segment": data["segment"],
}),
    );

    return res.statusCode == 200;
  }

  // -----------------------------
  // DELETE SHOP
  // -----------------------------
  Future<bool> deleteShop(String shopId) async {
    final res = await http.delete(
      Uri.parse("$base/shops/$shopId"),
      headers: {
        "Authorization": "Bearer ${AuthService.token}",
      },
    );

    return res.statusCode == 200;
  }
}
