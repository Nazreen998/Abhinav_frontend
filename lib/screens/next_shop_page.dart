// ignore_for_file: use_build_context_synchronously, unused_import

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

    try {
      final res = await ApiService.getNextShops(); // 🔥 NEW METHOD
      shops = List<Map<String, dynamic>>.from(res["shops"] ?? []);
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
          // ✅ PREMIUM CURVED HEADER
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
                  const SizedBox(height: 20),

                  // ✅ HEADER TITLE
                  const Row(
                    children: [
                      SizedBox(width: 4),
                      Text(
                        "Next Shops",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ✅ FLOATING CARD
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
                                    itemBuilder: (_, i) {
                                      final s = shops[i];
                                      return shopCard(s);
                                    },
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(
          color: Colors.blue.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 SHOP NAME
          Text(
            s["shop_name"] ?? "",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),

          const SizedBox(height: 6),

          // 🔹 ADDRESS
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  s["address"] ?? "",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 🔹 PREMIUM LAT/LNG BADGE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.blue.withOpacity(0.08),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.my_location,
                  size: 16,
                  color: Color(0xFF005BBB),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Lat: ${lat.toStringAsFixed(9)}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 14,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Lng: ${lng.toStringAsFixed(9)}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 BUTTON ROW
          // 🔹 PREMIUM BUTTON ROW
          Row(
            children: [
              // ✅ MAPS BUTTON (Outlined Modern)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => openMaps(lat, lng),
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text(
                    "Maps",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF005BBB),
                    side: BorderSide(
                      color: const Color(0xFF005BBB).withOpacity(0.4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ✅ MATCH BUTTON (Main Premium CTA)
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
                  icon: const Icon(
                    Icons.verified,
                    size: 18,
                    color: Colors.amber,
                  ),
                  label: const Text(
                    "Match",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    elevation: 4,
                    shadowColor: Colors.black26,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
