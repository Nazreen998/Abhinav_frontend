import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/pending_shop_model.dart';
import '../services/pending_shop_service.dart';
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
  bool approving = false; // 🔥 FIX 1

  bool get isMaster =>
      widget.user["role"].toString().toLowerCase() == "master";

  bool get isManager =>
      widget.user["role"].toString().toLowerCase() == "manager";

  @override
  void initState() {
    super.initState();
    loadPendingShops();
  }

  // ================= LOAD PENDING SHOPS =================
  Future<void> loadPendingShops() async {
    setState(() => loading = true);

    try {
      final res = await pendingService.getPendingShops();
      pendingShops =
          res.map((e) => PendingShopModel.fromJson(e)).toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading pending shops")),
        );
      }
    }

    if (mounted) setState(() => loading = false);
  }

  // ================= APPROVE =================
  Future<void> approveShop(String id) async {
    if (approving) return;

    setState(() => approving = true);

    final ok = await pendingService.approveShop(id);

    setState(() => approving = false);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Shop Approved Successfully")),
      );

      // 🔥 tell ShopListPage to refresh
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Approval failed")),
      );
    }
  }

  // ================= REJECT =================
  Future<void> rejectShop(String id) async {
    final ok = await pendingService.rejectShop(id);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Shop Rejected")),
      );
      loadPendingShops();
    }
  }

  @override
  Widget build(BuildContext context) {
    // SALESMAN BLOCK
    if (!isMaster && !isManager) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Access Denied",
            style: TextStyle(fontSize: 22, color: Colors.red),
          ),
        ),
      );
    }

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
          child: Column(
            children: [
              // ================= HEADER =================
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Pending Shops",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ================= BODY =================
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
                            itemBuilder: (_, i) =>
                                _pendingCard(pendingShops[i]),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= PENDING CARD =================
  Widget _pendingCard(PendingShopModel shop) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          if (shop.imageBase64 != null && shop.imageBase64!.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FullImagePage(base64Image: shop.imageBase64!),
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

          const SizedBox(height: 12),

          Text(
            shop.shopName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF003366),
            ),
          ),

          const SizedBox(height: 6),

          Text("Address: ${shop.address}"),
          Text("Segment: ${shop.segment}"),
          Text(
            "Created By: ${shop.createdBy ?? "Salesman"}",
            style: const TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 14),

          // APPROVE / REJECT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: approving ? null : () => approveShop(shop.mongoId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: approving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Approve"),
              ),
              ElevatedButton(
                onPressed: approving ? null : () => rejectShop(shop.mongoId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Reject"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
