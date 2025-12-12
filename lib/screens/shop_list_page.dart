import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'edit_shop_page.dart';

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

  @override
  void initState() {
    super.initState();

    role = widget.user["role"].toString().toLowerCase();
    segment = (widget.user["segment"] ?? "").toString().toLowerCase();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    fadeAnim = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    loadShops();
  }

  // ------------------------------------------------------
  // LOAD SHOPS (FIXED)
  // ------------------------------------------------------
  Future<void> loadShops() async {
    if (!mounted) return;
    setState(() => loading = true);

    final res = await ApiService.getShops();

    // 🔥 FIX: API returns { success, shops }
    final List all = res;

    // ROLE BASED FILTER
    if (role == "master") {
      filtered = all;
    } else {
      filtered = all.where((shop) {
        final shopSeg =
            (shop["segment"] ?? "").toString().toLowerCase();
        return shopSeg == segment;
      }).toList();
    }

    shops = filtered;

    controller.forward();

    if (!mounted) return;
    setState(() => loading = false);
  }

  // ------------------------------------------------------
  // SEARCH
  // ------------------------------------------------------
  List get searchResult {
    final q = search.toLowerCase();
    return shops.where((shop) {
      final name = (shop["shopName"] ?? shop["shop_name"] ?? "")
          .toString()
          .toLowerCase();
      final address = (shop["shopAddress"] ?? shop["address"] ?? "")
          .toString()
          .toLowerCase();
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
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

  // ------------------------------------------------------
  // SHOP CARD
  // ------------------------------------------------------
  Widget buildShopCard(Map shop) {
    final seg = shop["segment"].toString().toUpperCase();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                shop["shopName"] ?? shop["shop_name"] ?? "",
                style: const TextStyle(
                  color: Color(0xFF003366),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (role == "master" || role == "manager") ...[
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditShopPage(shop: shop),
                          ),
                        ).then((refresh) {
                          if (refresh == true) loadShops();
                        });
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
                                child: const Text("Cancel"),
                              ),
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
                              await ApiService.deleteShop(shop["_id"]);
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
            shop["shopAddress"] ?? shop["address"] ?? "",
            style: const TextStyle(color: Colors.black54, fontSize: 15),
          ),

          const SizedBox(height: 10),

          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              seg,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
