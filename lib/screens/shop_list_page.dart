// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/shop_service.dart';
import 'edit_shop_page.dart';
import 'pending_shops_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'match_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

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

  Future<void> showImageUploadDialog(Map<String, dynamic> shop) async {
    final ImagePicker picker = ImagePicker();
    String? base64Image;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Upload Shop Image"),
          content: const Text("Select image to upload."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final XFile? pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);

                if (pickedFile == null) return;

                final bytes = await File(pickedFile.path).readAsBytes();

                base64Image = base64Encode(bytes);

                final ok = await ApiService.updateShopImage(
                  shop["shop_id"],
                  base64Image!,
                );

                if (ok) {
                  Navigator.pop(context);
                  await loadShops();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Image uploaded successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Upload failed"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Upload"),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------
  // openMaps
  // ------------------------------------------------------
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

  // ------------------------------------------------------
  // LOAD SHOPS (FIXED)
  // ------------------------------------------------------
  Future<void> loadShops() async {
    if (!mounted) return;
    setState(() => loading = true);

    final List res = await ApiService.getShops();

    final approved = res.where((shop) {
      return shop["status"] == "approved" && shop["isDeleted"] != true;
    }).toList();

    if (role == "master") {
      filtered = approved;
    } else {
      filtered = approved.where((shop) {
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
  Widget buildShopCard(Map<String, dynamic> shop) {
    final double lat = double.tryParse(shop["lat"]?.toString() ?? "0") ?? 0;
    final double lng = double.tryParse(shop["lng"]?.toString() ?? "0") ?? 0;
    final seg = (shop["segment"] ?? "").toString().toUpperCase();

    final String imageUrl = (shop["shopImage"] ?? "").toString();
    final bool imageEmpty = imageUrl.isEmpty;

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
          // 🔹 SHOP IMAGE
          Stack(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: imageEmpty
                      ? Container(
                          height: 160,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child:
                                Icon(Icons.store, size: 40, color: Colors.grey),
                          ),
                        )
                      : Image.memory(
                          base64Decode(imageUrl),
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )),

              // 🔥 ADD BADGE (only salesman + image empty)
              if (role == "salesman" && imageEmpty)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => showImageUploadDialog(shop),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),
          // 🔹 SHOP NAME
          Text(
            shop["shopName"] ?? shop["shop_name"] ?? "",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),

          const SizedBox(height: 6),

          // 🔹 ADDRESS + SEGMENT
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  shop["shopAddress"] ?? shop["address"] ?? "",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF005BBB), Color(0xFF003F8C)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  seg,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 🔹 LAT / LNG
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
                const Icon(Icons.my_location,
                    size: 16, color: Color(0xFF005BBB)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Lat: ${lat.toStringAsFixed(6)}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
                    "Lng: ${lng.toStringAsFixed(6)}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 SALESMAN BUTTONS
          if (role == "salesman") ...[
            Row(
              children: [
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
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MatchPage(shop: shop),
                        ),
                      );

                      // ✅ Always refresh after returning
                      await loadShops();
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

          // 🔹 MASTER / MANAGER FOOTER
          // 🔹 MASTER / MANAGER FOOTER (Enhanced UI)
          if (role == "master" || role == "manager") ...[
            const SizedBox(height: 10),
            Row(
              children: [
                // 👤 Created By (Styled)
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          shop["createdByUserName"] ?? "Unknown",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ✏️ Edit (Soft Button Style)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D47A1).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit,
                      size: 18,
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
                ),

                const SizedBox(width: 6),

                // 🗑 Delete (Soft Red)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
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
                        final id = shop["shop_id"]?.toString();

                        if (id == null || id.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("Shop ID missing"),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        final ok = await ApiService.deleteShop(id);

                        if (ok) {
                          loadShops();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("Shop deleted successfully"),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("Failed to delete shop"),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
