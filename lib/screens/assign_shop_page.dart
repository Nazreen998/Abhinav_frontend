// ignore_for_file: avoid_print

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/user_model.dart';
import '../models/shop_model.dart';
import '../services/user_service.dart';
import '../services/shop_service.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart' as api;

import 'home_page.dart';

class AssignShopPage extends StatefulWidget {
  const AssignShopPage({super.key});

  @override
  State<AssignShopPage> createState() => _AssignShopPageState();
}

class _AssignShopPageState extends State<AssignShopPage> {
  List<UserModel> users = [];
  List<ShopModel> allShops = [];
  List<ShopModel> segmentShops = [];

  UserModel? selectedUser;
  Position? userLocation;

  List<String> selectedShopIds = [];
  bool loading = true;

  TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadInitial();
  }

  Future<void> loadInitial() async {
    setState(() => loading = true);

    String role = AuthService.currentUser?["role"] ?? "";
    String segment = AuthService.currentUser?["segment"] ?? "";

    // FETCH USERS
    users = await UserService().getUsers();

    // FETCH SHOPS
    allShops = await ShopService().getShops();

    // SEGMENT FILTER FOR MANAGER
    if (role == "manager") {
      users = users.where((u) => u.segment.toLowerCase() == segment.toLowerCase()).toList();
      allShops = allShops.where((s) => s.segment.toLowerCase() == segment.toLowerCase()).toList();
    }

    setState(() => loading = false);
  }

  // FILTER SHOPS FOR SELECTED USER'S SEGMENT
  void filterShops() {
    if (selectedUser == null) return;

    setState(() {
      segmentShops = allShops
          .where((s) => s.segment.toLowerCase() == selectedUser!.segment.toLowerCase())
          .toList();

      selectedShopIds.clear();
    });
  }

  // GET LOCATION
  Future<void> getUserLocation() async {
    if (kIsWeb) {
      try {
        userLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        );
      } catch (e) {
        print("WEB Location Blocked → fallback 0,0");
        userLocation = Position(
          latitude: 0,
          longitude: 0,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
      return;
    }

    // MOBILE / WINDOWS
    bool service = await Geolocator.isLocationServiceEnabled();
    if (!service) return showMsg("Enable Location");

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        return showMsg("Location Permission Denied");
      }
    }

    try {
      userLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print("Mobile Location Error, fallback 0,0");
      userLocation = Position(
        latitude: 0,
        longitude: 0,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
  }

  // DISTANCE LOGIC (still used for sorting)
  double distance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);

    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  // ASSIGN SHOPS (NEW BACKEND)
 Future<void> assignShopsToSalesman() async {
   if (!mounted) return;

  if (AuthService.token == null) {
    await AuthService.init();
  }
  if (selectedUser == null) return showMsg("Select a user first");
  if (selectedShopIds.isEmpty) return showMsg("Select at least one shop");

  await getUserLocation();

  List<Map<String, dynamic>> arranged = [];

  for (var shop in segmentShops) {
    if (selectedShopIds.contains(shop.shopId.toString())) {
      arranged.add({
        "shop": shop,
        "distance": distance(
          userLocation!.latitude,
          userLocation!.longitude,
          shop.lat,
          shop.lng,
        ),
      });
    }
  }

  arranged.sort((a, b) => a["distance"].compareTo(b["distance"]));

  for (var s in arranged) {
    final ShopModel shop = s["shop"];

    await api.ApiService.assignShop(
  shop.shopName,
  selectedUser!.name,
  shop.segment,
);

  }
if (!mounted) return;

Future.delayed(const Duration(milliseconds: 400), () {
  if (!mounted) return;
  Navigator.pop(context);
});


}

  void showMsg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  // UI
  @override
  Widget build(BuildContext context) {
    String role = AuthService.currentUser?["role"] ?? "";

    if (role != "master" && role != "manager") {
      return const Scaffold(
        body: Center(
          child: Text("Access Denied", style: TextStyle(color: Colors.red, fontSize: 20)),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFF007BFF), Color(0xFF66B2FF), Color(0xFFB8E0FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 28, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text("Assign Shops",
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        child: Column(
                          children: [
                            DropdownButtonFormField<UserModel>(
                              value: selectedUser,
                              decoration: customInput("Select User"),
                              items: users
                                  .map((u) =>
                                      DropdownMenuItem(value: u, child: Text("${u.name} (${u.segment})")))
                                  .toList(),
                              onChanged: (u) {
                                selectedUser = u;
                                filterShops();
                              },
                            ),

                            const SizedBox(height: 15),

                            TextField(
                              controller: searchCtrl,
                              decoration: InputDecoration(
                                hintText: "Search shops...",
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onChanged: (txt) {
                                if (selectedUser == null) return;

                                setState(() {
                                  segmentShops = allShops
                                      .where((s) => s.segment.toLowerCase() ==
                                          selectedUser!.segment.toLowerCase())
                                      .where((s) =>
                                          s.shopName.toLowerCase().contains(txt.toLowerCase()) ||
                                          s.address.toLowerCase().contains(txt.toLowerCase()))
                                      .toList();
                                });
                              },
                            ),

                            const SizedBox(height: 15),

                            Expanded(
                              child: ListView.builder(
                                itemCount: segmentShops.length,
                                itemBuilder: (_, i) {
                                  final shop = segmentShops[i];
                                  final isChecked =
                                      selectedShopIds.contains(shop.shopId.toString());

                                  return Card(
                                    elevation: 2,
                                    child: CheckboxListTile(
                                      value: isChecked,
                                      title: Text(shop.shopName,
                                          style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text(shop.address),
                                      onChanged: (v) {
                                        setState(() {
                                          if (v == true) {
                                            selectedShopIds.add(shop.shopId.toString());
                                          } else {
                                            selectedShopIds.remove(shop.shopId.toString());
                                          }
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: assignShopsToSalesman,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                child: const Text("Assign Shops",
                                    style: TextStyle(fontSize: 18)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  InputDecoration customInput(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.blueAccent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
    );
  }
}
