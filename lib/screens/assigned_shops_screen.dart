// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AssignedShopsScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const AssignedShopsScreen({super.key, required this.user});

  @override
  State<AssignedShopsScreen> createState() => _AssignedShopsScreenState();
}

class _AssignedShopsScreenState extends State<AssignedShopsScreen> {
  List<Map<String, dynamic>> shops = [];
  bool loading = true;

  // Dropdown (Manager/Master only)
  List<dynamic> users = [];
  String? selectedSalesmanId;

  String get role => (widget.user["role"] ?? "").toString().toLowerCase();
  String get mySegment =>
      (widget.user["segment"] ?? "").toString().toLowerCase();

  bool get canEdit => role == "manager" || role == "master";

  @override
  void initState() {
    super.initState();

    if (role == "salesman") {
      // Salesman -> directly load his assigned shops
      loadAssignedForSalesman(widget.user["user_id"].toString());
    } else {
      // Manager/Master -> load dropdown users first
      loadUsers();
    }
  }

  // --------------------------------------------------
  // LOAD USERS FOR DROPDOWN
  // --------------------------------------------------
  Future<void> loadUsers() async {
    setState(() => loading = true);

    final all = await ApiService.getUsers();

    // only salesman
    final salesmen = all
        .where((u) => (u["role"] ?? "").toString().toLowerCase() == "salesman")
        .toList();

    // manager -> only same segment
    List<dynamic> filtered = salesmen;
    if (role == "manager") {
      filtered = salesmen.where((u) {
        return (u["segment"] ?? "").toString().toLowerCase() == mySegment;
      }).toList();
    }

    final firstId =
        filtered.isNotEmpty ? filtered[0]["user_id"].toString() : null;

    setState(() {
      users = filtered;
      selectedSalesmanId = firstId;
    });

    if (firstId != null) {
      await loadAssignedForSalesman(firstId);
    } else {
      setState(() {
        shops = [];
        loading = false;
      });
    }
  }

  // --------------------------------------------------
  // LOAD ASSIGNED SHOPS FOR A SALESMAN
  // --------------------------------------------------
  Future<void> loadAssignedForSalesman(String salesmanId) async {
    setState(() => loading = true);

    final assigned = await ApiService.getAssignedShops(salesmanId);

    print("ASSIGNED FROM API => $assigned");
    print("ASSIGNED LENGTH => ${assigned.length}");

    final List<Map<String, dynamic>> mapped = [];

    for (final a in assigned) {
      mapped.add({
        "_id": (a["assignment_id"] ?? a["sk"] ?? "").toString(),
        "sk": (a["sk"] ?? "").toString(),
        "shop_id": (a["shop_id"] ?? "").toString(),
        "shop_name": (a["shop_name"] ?? "").toString(),
        "address": (a["address"] ?? "").toString(),
        "segment": (a["segment"] ?? "").toString(),
        "sequence": int.tryParse((a["sequence"] ?? "0").toString()) ?? 0,
      });
    }

    mapped.sort(
      (x, y) => (x["sequence"] as int).compareTo(y["sequence"] as int),
    );

    if (!mounted) return;

    setState(() {
      shops = mapped;
      loading = false;
    });
  }

  // --------------------------------------------------
  // SAVE ORDER
  // --------------------------------------------------
  Future<void> saveOrder() async {
    final salesmanIdToUse =
        role == "salesman" ? widget.user["user_id"].toString() : selectedSalesmanId;

    if (salesmanIdToUse == null) return;

    final ok = await ApiService.reorderAssignedShops(
      salesmanIdToUse,
      shops.map<String>((e) => e["sk"].toString()).toList(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? "Order Updated ✅" : "Update Failed ❌"),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );

    if (ok) loadAssignedForSalesman(salesmanIdToUse);
  }

  // --------------------------------------------------
  // DELETE ASSIGNED SHOP
  // --------------------------------------------------
  Future<void> deleteAssignedShop(String sk) async {
    final salesmanIdToUse =
        role == "salesman" ? widget.user["user_id"].toString() : selectedSalesmanId;

    if (salesmanIdToUse == null) return;

    final ok = await ApiService.removeAssignedShop(salesmanIdToUse, sk);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? "Removed ✅" : "Remove Failed ❌"),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );

    if (ok) loadAssignedForSalesman(salesmanIdToUse);
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: shops.isEmpty ? null : saveOrder,
              label: const Text("Save Order"),
              icon: const Icon(Icons.save),
            )
          : null,
      body: Stack(
        children: [
          // HEADER BG
          Container(
            height: 260,
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

                  // TOP BAR
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "Assigned Shops",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // DROPDOWN
                  if (canEdit)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButton<String>(
                        value: selectedSalesmanId,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text("Select Salesman"),
                        items: users.map((u) {
                          return DropdownMenuItem(
                            value: u["user_id"].toString(),
                            child: Text("${u["name"]} (${u["segment"]})"),
                          );
                        }).toList(),
                        onChanged: (v) async {
                          if (v == null) return;
                          setState(() => selectedSalesmanId = v);
                          await loadAssignedForSalesman(v);
                        },
                      ),
                    ),

                  const SizedBox(height: 18),

                  // LIST BOX
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
                          ? const Center(child: CircularProgressIndicator())
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
                                  buildDefaultDragHandles: false,
                                  onReorder: canEdit
                                      ? (oldIndex, newIndex) {
                                          setState(() {
                                            if (newIndex > oldIndex) newIndex--;
                                            final item = shops.removeAt(oldIndex);
                                            shops.insert(newIndex, item);
                                          });
                                        }
                                      : (a, b) {},
                                  itemBuilder: (context, i) {
                                    return _shopCard(shops[i], i);
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

  // --------------------------------------------------
  // SHOP CARD
  // --------------------------------------------------
  Widget _shopCard(Map<String, dynamic> shop, int i) {
    return Container(
      key: ValueKey(shop["_id"]),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // NUMBER
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF002D62), Color(0xFF005BBB)],
              ),
              borderRadius: BorderRadius.circular(12),
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

          const SizedBox(width: 12),

          // INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shop["shop_name"] ?? "",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Segment: ${shop["segment"] ?? ""}",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  shop["address"] ?? "",
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // ACTIONS
          if (canEdit) ...[
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteAssignedShop(shop["sk"]),
            ),
            ReorderableDragStartListener(
              index: i,
              child: const Icon(Icons.drag_handle, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}