// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'modify_assigned_page.dart';

class AssignedShopsScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const AssignedShopsScreen({super.key, required this.user});

  @override
  State<AssignedShopsScreen> createState() => _AssignedShopsScreenState();
}

class _AssignedShopsScreenState extends State<AssignedShopsScreen> {
  List<dynamic> shops = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAssignedShops();
  }

  Future<void> loadAssignedShops() async {
    setState(() => loading = true);

    final role = widget.user["role"].toString().toLowerCase();
    final mySegment = widget.user["segment"];

    final assigned =
        await ApiService.getAssignedShops(widget.user["user_id"].toString());
    final allShops = await ApiService.getShops();

    List filtered = [];

    if (role == "master") {
      filtered = assigned;
    } else if (role == "manager") {
      filtered = assigned
          .where((a) =>
              (a["segment"] ?? "").toString().toLowerCase() ==
              (mySegment ?? "").toString().toLowerCase())
          .toList();
    } else {
      filtered = assigned
          .where((a) =>
              a["salesman_id"].toString() == widget.user["user_id"].toString())
          .toList();
    }

    final mapped = filtered.map((a) {
      final match = allShops.firstWhere(
        (s) => s["shop_id"].toString() == a["shop_id"].toString(),
        orElse: () => <String, dynamic>{},
      );

      return {
        "_id": a["_id"] ?? a["shop_id"],
        "sk": a["sk"],
        "shop_id": a["shop_id"],
        "shop_name": match["shop_name"] ?? a["shop_name"] ?? "",
        "address": match["address"] ?? a["address"] ?? "",
        "segment": a["segment"] ?? match["segment"] ?? "",
        "sequence": int.tryParse(a["sequence"]?.toString() ?? "0") ?? 0,
      };
    }).toList();

    mapped.sort((a, b) => (a["sequence"] ?? 0).compareTo(b["sequence"] ?? 0));

    if (!mounted) return;

    setState(() {
      shops = mapped;
      loading = false;
    });
  }

  Future<void> saveOrder() async {
    final ok = await ApiService.reorderAssignedShops(
      widget.user["user_id"].toString(),
      shops.map<String>((e) => e["sk"].toString()).toList(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? "Order Updated" : "Update Failed"),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );

    if (ok) loadAssignedShops();
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.user["role"].toString().toLowerCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: Stack(
        children: [
          Container(
            height: 230,
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
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Assigned Shops",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.user["name"] ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
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
                                    "No assigned shops",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                )
                              : ReorderableListView.builder(
                                  itemCount: shops.length,
                                  onReorder: (oldIndex, newIndex) {
                                    if (role == "master" || role == "manager") {
                                      setState(() {
                                        if (newIndex > oldIndex) newIndex--;
                                        final item = shops.removeAt(oldIndex);
                                        shops.insert(newIndex, item);
                                      });
                                    }
                                  },
                                  itemBuilder: (context, i) {
                                    return _shopCard(shops[i], i, role);
                                  },
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

  Widget _shopCard(Map shop, int i, String role) {
    return Container(
      key: ValueKey(shop["_id"]),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF002D62),
                  Color(0xFF005BBB),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                "${i + 1}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shop["shop_name"]?.toString() ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Segment: ${shop["segment"] ?? ""}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          if (role == "master" || role == "manager")
            const Icon(
              Icons.drag_handle,
              color: Colors.grey,
            ),
        ],
      ),
    );
  }
}
