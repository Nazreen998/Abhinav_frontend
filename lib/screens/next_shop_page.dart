import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'match_page.dart';
import '../models/shop_model.dart';
import '../services/assign_service.dart';
import '../services/auth_service.dart';

class NextShopPage extends StatefulWidget {
  const NextShopPage({super.key});

  @override
  State<NextShopPage> createState() => _NextShopPageState();
}

class _NextShopPageState extends State<NextShopPage> {
  final AssignService assignService = AssignService();
  List<ShopModel> shops = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAssignedShops();
  }

  // ---------------------------------------------------------
  // LOAD NEXT SHOPS (distance sorted)
  // ---------------------------------------------------------
  Future<void> loadAssignedShops() async {
    loading = true;
    setState(() {});

    final user = AuthService.currentUser;
    if (user == null) {
      loading = false;
      setState(() {});
      return;
    }

    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enable location: $e")),
      );
      loading = false;
      setState(() {});
      return;
    }

    // API → /assign/next/:userId
    final result = await assignService.getNextShops(
      user["user_id"],
      position.latitude,
      position.longitude,
    );

    shops = result.map((e) => ShopModel.fromJson(e)).toList();

    loading = false;
    setState(() {});
  }

  // ---------------------------------------------------------
  // OPEN GOOGLE MAPS
  // ---------------------------------------------------------
  Future<void> openMaps(double lat, double lng) async {
    final Uri url = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007BFF), Color(0xFF66B2FF), Color(0xFFB8E0FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              size: 28, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          "Next Shops",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // NO SHOPS
                    if (shops.isEmpty)
                      const Expanded(
                        child: Center(
                          child: Text(
                            "No assigned shops found",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    else
                      // SHOPS LIST
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: loadAssignedShops,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(14),
                            itemCount: shops.length,
                            itemBuilder: (_, i) {
                              final s = shops[i];
                              return shopCard(s);
                            },
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // SHOP CARD UI
  // ---------------------------------------------------------
  Widget shopCard(ShopModel s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 3),
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.shopName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF003366),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            s.address,
            style: const TextStyle(color: Colors.black54, fontSize: 15),
          ),

          const SizedBox(height: 10),

          Text("Lat: ${s.lat}, Lng: ${s.lng}",
              style: const TextStyle(color: Colors.black87)),

          const SizedBox(height: 18),

          // OPEN MAPS BUTTON
          ElevatedButton(
            onPressed: () => openMaps(s.lat, s.lng),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
            ),
            child: const Text("Open in Google Maps"),
          ),

          const SizedBox(height: 10),

          // MATCH PAGE BUTTON
          ElevatedButton(
            onPressed: () {
              Navigator.push(
               context,
                MaterialPageRoute(
                builder: (_) => MatchPage(shop: s.toJson()),
  ),
);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text("MATCH"),
          ),
        ],
      ),
    );
  }
}
