// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'match_page.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class NextShopPage extends StatefulWidget {
  const NextShopPage({super.key});

  @override
  State<NextShopPage> createState() => _NextShopPageState();
}

class _NextShopPageState extends State<NextShopPage> {
  // 🔥 IMPORTANT: RAW MAP LIST (NO ShopModel)
  List<Map<String, dynamic>> shops = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAssignedShops();
  }

  // ---------------------------------------------------------
  // LOAD NEXT SHOPS (FROM /assigned/salesman/today)
  // ---------------------------------------------------------
  Future<void> loadAssignedShops() async {
    setState(() => loading = true);

    final user = AuthService.currentUser;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final data = await ApiService.getSalesmanToday();

      final pending = data["pending"] ?? [];

      // 🔥 CAST TO RAW MAP
      shops = List<Map<String, dynamic>>.from(pending);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Load error: $e")),
      );
    }

    setState(() => loading = false);
  }

  // ---------------------------------------------------------
  // OPEN GOOGLE MAPS
  // ---------------------------------------------------------
  Future<void> openMaps(double lat, double lng) async {
    final Uri url = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving",
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: Stack(
        children: [
          // ✅ Premium Curved Header
          Container(
            height: 240,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF002D62),
                  Color(0xFF005BBB),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),

                  // ✅ Header Row
                  Row(
                    children: [
                      const Text(
                        "Next Shops",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),

                      // Refresh Icon
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: loadAssignedShops,
                      )
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ✅ Floating White Body Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: loading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : shops.isEmpty
                              ? const Center(
                                  child: Text(
                                    "No assigned shops found",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: loadAssignedShops,
                                  child: ListView.builder(
                                    itemCount: shops.length,
                                    itemBuilder: (_, i) => shopCard(shops[i]),
                                  ),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // SHOP CARD (RAW MAP)
  // ---------------------------------------------------------
  Widget shopCard(Map<String, dynamic> s) {
    final double lat = double.tryParse(s["lat"]?.toString() ?? "0") ?? 0;
    final double lng = double.tryParse(s["lng"]?.toString() ?? "0") ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF005BBB).withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Top Row (Icon + Name + Badge)
          Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF002D62),
                      Color(0xFF005BBB),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.store,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  s["shop_name"] ?? "",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "ASSIGNED",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 🔹 Address Row
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  s["address"] ?? "",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 🔹 Lat/Lng
          Text(
            "Lat: $lat, Lng: $lng",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 18),

          // 🔹 Buttons Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => openMaps(lat, lng),
                  icon: const Icon(Icons.map, size: 18, color: Colors.white),
                  label: const Text("Maps"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005BBB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MatchPage(shop: s),
                      ),
                    );
                  },
                  icon:
                      const Icon(Icons.verified, size: 18, color: Colors.white),
                  label: const Text("MATCH"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
