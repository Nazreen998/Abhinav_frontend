import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shop_model.dart';
import '../services/auth_service.dart';

class ShopService {
  static const String base =
      "https://abhinav-backend-production.up.railway.app/api";

  String get shopBaseUrl => "$base/shop";
  String get pendingBaseUrl => "$base/pending";

  Future<List<ShopModel>> getShops() async {
  // WAIT until token is loaded
  if (AuthService.token == null) {
    await AuthService.init();
  }

  final res = await http.get(
    Uri.parse("$shopBaseUrl/all"),
    headers: {
      "Authorization": "Bearer ${AuthService.token ?? ''}",
    },
  );

  if (res.statusCode != 200) {
    print("SHOP ERROR: ${res.body}");
    return [];
  }

  final body = jsonDecode(res.body);
  final List shops = body["shops"] ?? [];

  return shops.map((e) => ShopModel.fromJson(e)).toList();
}


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

  Future<bool> addShop(ShopModel shop) async {
    final res = await http.post(
      Uri.parse("$shopBaseUrl/add"),
      headers: {
        "Authorization": "Bearer ${AuthService.token}"},
      body: jsonEncode(shop.toJson()),
    );

    return res.statusCode == 200;
  }

  Future<bool> approveShop(String mongoId) async {
    final res = await http.post(
      Uri.parse("$pendingBaseUrl/approve/$mongoId"),
      headers: {"Authorization": "Bearer ${AuthService.token}"},
    );

    return res.statusCode == 200;
  }
}
