import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ShopListPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ShopListPage({super.key, required this.user});

  @override
  State<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage>
    with SingleTickerProviderStateMixin {
  List shops = [];
  List filtered = [];

  bool loading = true;
  String search = "";

  late AnimationController controller;
  late Animation<double> fadeAnim;

  String role = "";
  String segment = "";
  String userId = "";

  @override
  void initState() {
    super.initState();

    role = widget.user["role"].toString().toLowerCase();
    segment = widget.user["segment"] ?? "";
    userId = widget.user["user_id"] ?? "";

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    fadeAnim = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    loadShops();
  }

  // ------------------------------------------------------------
  // LOAD SHOPS BASED ON ROLE
  // ------------------------------------------------------------
  Future<void> loadShops() async {
    if (!mounted) return;
    setState(() => loading = true);

    List<dynamic> res = [];

    if (role == "master") {
      res = await ApiService.getShops();
    } 
    else if (role == "manager") {
      final all = await ApiService.getShops();
      res = all
          .where((s) =>
              (s["segment"] ?? "").toString().toLowerCase() ==
              segment.toLowerCase())
          .toList();
    } 
    else {
      // ⭐ SALESMAN MERGE LOGIC (exact same fix as AssignedShopsScreen)
      final assigned = await ApiService.getAssignedShops();
      final all = await ApiService.getShops();

      final userAssigned =
          assigned.where((a) => a["user_id"] == userId).toList();

      res = userAssigned.map((a) {
        final match = all.firstWhere(
          (s) => s["shop_id"] == a["shop_id"],
          orElse: () => {},
        );

        return {
          "shop_id": a["shop_id"],
          "shop_name": match["shop_name"] ?? "Unknown Shop",
          "address": match["address"] ?? "",
          "segment": match["segment"] ?? "",
        };
      }).toList();
    }

    if (!mounted) return;

    shops = res;
    filtered = shops;

    controller.forward();

    if (!mounted) return;
    setState(() => loading = false);
  }

  // ------------------------------------------------------------
  // SEARCH FILTER
  // ------------------------------------------------------------
  List get searchResult {
    final q = search.toLowerCase();
    return filtered.where((shop) {
      final name = shop["shop_name"].toString().toLowerCase();
      final address = shop["address"].toString().toLowerCase();
      return name.contains(q) || address.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final listToShow = searchResult;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF007BFF),
              Color(0xFF66B2FF),
              Color(0xFFB8E0FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // TOP BAR
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Shop List",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // SEARCH BOX
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: (v) => setState(() => search = v),
                  decoration: InputDecoration(
                    hintText: "Search shops...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : listToShow.isEmpty
                        ? const Center(
                            child: Text(
                              "No shops found",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : FadeTransition(
                            opacity: fadeAnim,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: listToShow.length,
                              itemBuilder: (_, i) =>
                                  buildShopCard(listToShow[i]),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SHOP CARD UI
  // ------------------------------------------------------------
  Widget buildShopCard(Map shop) {
    final seg = shop["segment"].toString().toUpperCase();

    Color segColor = seg == "FMCG"
        ? Colors.blue
        : seg == "PIPES"
            ? Colors.orange
            : Colors.purple;

    Color segBG = seg == "FMCG"
        ? Colors.blue.shade100
        : seg == "PIPES"
            ? Colors.orange.shade100
            : Colors.purple.shade100;

    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------- TOP ---------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                shop["shop_name"] ?? "",
                style: const TextStyle(
                  color: Color(0xFF003366),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (role == "master") ...[
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        print("EDIT → ${shop['shop_id']}");
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final yes = await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete Shop?"),
                            content: const Text(
                                "Are you sure you want to delete this shop?"),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancel")),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );

                        if (yes == true) {
                          final ok =
                              await ApiService.deleteShop(shop["shop_id"]);
                          if (ok) loadShops();
                        }
                      },
                    ),
                  ],
                )
              ]
            ],
          ),

          const SizedBox(height: 6),

          Text(
            shop["address"] ?? "",
            style: const TextStyle(color: Colors.black54, fontSize: 15),
          ),

          const SizedBox(height: 10),

          // SEGMENT BADGE
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: segBG,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              seg,
              style: TextStyle(
                color: segColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
