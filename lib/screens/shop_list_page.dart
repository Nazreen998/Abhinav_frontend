// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'edit_shop_page.dart';
import 'pending_shops_page.dart';

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
    final List all = res.where((shop) {
      return shop["status"] == "approved" && shop["isDeleted"] != true;
    }).toList();

    // ROLE BASED FILTER
    if (role == "master") {
      filtered = all;
    } else {
      filtered = all.where((shop) {
        final shopSeg = (shop["segment"] ?? "").toString().toLowerCase();
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
      backgroundColor: const Color(0xFFF6F8FC),
      body: Stack(
        children: [
          // ✅ CURVED PREMIUM HEADER
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

                  // ✅ TOP BAR TITLE + ACTIONS
                  Row(
                    children: [
                      const Text(
                        "Shop List",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),

                      // 🔥 Pending Shops Button (UNCHANGED)
                      if (role == "master" || role == "manager")
                        IconButton(
                          icon: const Icon(Icons.pending_actions,
                              color: Colors.white, size: 28),
                          onPressed: () async {
                            final refreshed = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PendingShopsPage(user: widget.user),
                              ),
                            );

                            if (refreshed == true) {
                              loadShops();
                            }
                          },
                        ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ✅ FLOATING WHITE CARD (Premium Look)
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
                      child: Column(
                        children: [
                          // 🔍 SEARCH BAR
                          TextField(
                            onChanged: (v) => setState(() => search = v),
                            decoration: InputDecoration(
                              hintText: "Search shops...",
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: const Color(0xFFF4F7FC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ✅ SHOP LIST INSIDE CARD
                          Expanded(
                            child: loading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : listToShow.isEmpty
                                    ? const Center(
                                        child: Text(
                                          "No shops found",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      )
                                    : FadeTransition(
                                        opacity: fadeAnim,
                                        child: ListView.builder(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------
  // SHOP CARD
  // ------------------------------------------------------
  Widget buildShopCard(Map shop) {
    final seg = shop["segment"].toString().toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(
          color: Colors.blue.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 TOP ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⭐ Shop Icon Avatar
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF002D62),
                      Color(0xFF005BBB),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.store,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              // Shop Name + Address
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop["shopName"] ?? shop["shop_name"] ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            shop["shopAddress"] ?? shop["address"] ?? "",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              if (role == "master" || role == "manager")
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Color(0xFF0D47A1),
                      ),
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
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        final yes = await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete Shop?"),
                            content: const Text(
                                "Are you sure you want to delete this shop?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );

                        if (yes == true) {
                          final ok = await ApiService.deleteShop(shop["_id"]);
                          if (ok) loadShops();
                        }
                      },
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 14),

          // 🔹 Segment Badge + Divider Row
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  seg,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
