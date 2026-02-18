import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class PendingShopService {
  static const String base =
      "https://abhinav-backend.onrender.com/api";

  Map<String, String> get headers => {
        "Content-Type": "application/json",
        if (AuthService.token != null)
          "Authorization": "Bearer ${AuthService.token}",
      };

  // -------------------------------------------------------
  // GET PENDING SHOPS (MASTER / MANAGER)
  // -------------------------------------------------------
Future<List<dynamic>> getPendingShops() async {
  final url = Uri.parse("$base/shops/list");

  final res = await http.get(url, headers: headers);

  if (res.statusCode != 200) return [];

  final data = jsonDecode(res.body);
  final List shops = data["shops"] ?? [];

  // ✅ ONLY PENDING
  return shops.where((s) => s["isApproved"] == false).toList();
}
  // -------------------------------------------------------
  // APPROVE SHOP
  // -------------------------------------------------------
 Future<bool> approveShop(String shopId) async {
  final url = Uri.parse("$base/shops/approve/$shopId");

  final res = await http.put(url, headers: headers);

  if (res.statusCode != 200) return false;

  final data = jsonDecode(res.body);
  return data["success"] == true;
}
  // -------------------------------------------------------
  // REJECT SHOP
  // -------------------------------------------------------
Future<bool> rejectShop(String shopId) async {
  final url = Uri.parse("$base/shops/delete/$shopId");

  final res = await http.delete(url, headers: headers);

  if (res.statusCode != 200) return false;

  final data = jsonDecode(res.body);
  return data["success"] == true;
}

}
