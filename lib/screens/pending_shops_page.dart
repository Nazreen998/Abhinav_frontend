import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/pending_shop_model.dart';
import '../services/pending_shop_service.dart';
import '../services/auth_service.dart';
import 'full_image_page.dart';


class PendingShopsPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const PendingShopsPage({super.key, required this.user});

  @override
  State<PendingShopsPage> createState() => _PendingShopsPageState();
}

class _PendingShopsPageState extends State<PendingShopsPage> {
  final PendingShopService pendingService = PendingShopService();

  List<PendingShopModel> pendingShops = [];
  bool loading = true;

  bool get isMaster =>
      widget.user["role"].toString().toLowerCase() == "master";
  bool get isManager =>
      widget.user["role"].toString().toLowerCase() == "manager";

  @override
  void initState() {
    super.initState();
    loadPendingShops();
  }

  Future<void> loadPendingShops() async {
    loading = true;
    setState(() {});

    final res = await pendingService.getPendingShops();

    pendingShops = res.map((e) => PendingShopModel.fromJson(e)).toList();

    // MANAGER → segment filter
    if (isManager) {
      pendingShops = pendingShops
          .where((s) =>
              s.segment.toUpperCase() ==
              widget.user["segment"].toString().toUpperCase())
          .toList();
    }

    loading = false;
    setState(() {});
  }

  Future<void> approveShop(String id) async {
    final ok = await pendingService.approveShop(id);
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Shop Approved")));
      loadPendingShops();
    }
  }

  Future<void> rejectShop(String id) async {
    final ok = await pendingService.rejectShop(id);
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Shop Rejected")));
      loadPendingShops();
    }
  }

  @override
  Widget build(BuildContext context) {
    // SALESMAN → NO ACCESS
    if (!isMaster && !isManager) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Access Denied",
            style: TextStyle(color: Colors.red, fontSize: 22),
          ),
        ),
      );
    }

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
              // HEADER
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        size: 28, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Pending Shops",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : pendingShops.isEmpty
                        ? const Center(
                            child: Text(
                              "No Pending Shops",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: pendingShops.length,
                            itemBuilder: (_, i) {
                              final shop = pendingShops[i];

                              return Container(
                                padding: const EdgeInsets.all(20),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(20),
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
                                    // IMAGE PREVIEW (Base64)
if (shop.imageBase64 != null && shop.imageBase64!.isNotEmpty)
  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullImagePage(base64Image: shop.imageBase64!),
        ),
      );
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.memory(
        base64Decode(shop.imageBase64!),
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    ),
  ),


const SizedBox(height: 14),


                                    Text(
                                      shop.shopName,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF003366),
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text("Address: ${shop.address}",
                                        style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 15)),
                                    Text("Created By: ${shop.createdBy}",
                                        style: const TextStyle(
                                            color: Colors.black54)),
                                    Text("Segment: ${shop.segment}",
                                        style: const TextStyle(
                                            color: Colors.black54)),

                                    const SizedBox(height: 14),

                                    // MASTER + MANAGER → Approve/Reject
                                    if (isMaster || isManager)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () =>
                                                approveShop(shop.mongoId),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 18),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              "Approve",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                rejectShop(shop.mongoId),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 18),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              "Reject",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
