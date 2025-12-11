import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shop_model.dart';
import '../services/auth_service.dart';

class ShopService {
  static const String base = "https://abhinav-backend-5.onrender.com/api";

  String get shopBaseUrl => "$base/shops";

  // GET SHOPS ✔ FIXED
  Future<List<ShopModel>> getShops() async {
    if (AuthService.token == null) await AuthService.init();

    final res = await http.get(
      Uri.parse(shopBaseUrl),
      headers: {"Authorization": "Bearer ${AuthService.token}"},
    );

    if (res.statusCode != 200) {
      print("❌ SHOP ERROR: ${res.body}");
      return [];
    }

    final list = jsonDecode(res.body);
    return list.map<ShopModel>((e) => ShopModel.fromJson(e)).toList();
  }

  // UPDATE SHOP ✔ FIXED
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

  // DELETE SHOP ✔ FIXED
  Future<bool> deleteShop(String shopId) async {
    final res = await http.delete(
      Uri.parse("$shopBaseUrl/delete/$shopId"),
      headers: {"Authorization": "Bearer ${AuthService.token}"},
    );

    return res.statusCode == 200;
  }
}
