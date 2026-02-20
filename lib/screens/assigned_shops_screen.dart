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

  // Manager/Master dropdown
  List<dynamic> users = [];
  String? selectedSalesmanId;

  String get role => (widget.user["role"] ?? "").toString().toLowerCase();
  String get mySegment => (widget.user["segment"] ?? "").toString().toLowerCase();

  @override
  void initState() {
    super.initState();

    // ✅ Salesman -> direct load
    if (role == "salesman") {
      loadAssignedForSalesman(widget.user["user_id"].toString());
    } else {
      // ✅ Manager/Master -> load salesman list first
      loadUsers();
    }
  }

  // --------------------------------------------------
  // LOAD USERS (only for manager/master)
  // --------------------------------------------------
  Future<void> loadUsers() async {
    setState(() => loading = true);

    final all = await ApiService.getUsers();

    // only salesman
    final salesmen = all.where((u) {
      return (u["role"] ?? "").toString().toLowerCase() == "salesman";
    }).toList();

    // manager -> only same segment salesmen
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

    // load assigned for first salesman automatically
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
  // LOAD ASSIGNED SHOPS (by salesmanId)
  // --------------------------------------------------
 Future<void> loadAssignedForSalesman(String salesmanId) async {
  setState(() => loading = true);

  final assigned = await ApiService.getAssignedShops(salesmanId);

  print("ASSIGNED FROM API => $assigned");
  print("ASSIGNED LENGTH => ${assigned.length}");

  final List<Map<String, dynamic>> mapped = [];

  for (final a in assigned) {
    try {
      mapped.add({
        "_id": (a["assignment_id"] ?? a["sk"] ?? "").toString(),
        "sk": (a["sk"] ?? "").toString(),
        "shop_id": (a["shop_id"] ?? "").toString(),
        "shop_name": (a["shop_name"] ?? "").toString(),
        "address": (a["address"] ?? "").toString(),
        "segment": (a["segment"] ?? "").toString(),
        "sequence": int.tryParse((a["sequence"] ?? "0").toString()) ?? 0,
      });
    } catch (e) {
      print("❌ MAPPING ERROR => $e");
    }
  }

  mapped.sort((x, y) => (x["sequence"] as int).compareTo(y["sequence"] as int));

  print("MAPPED LENGTH => ${mapped.length}");
  print("MAPPED => $mapped");

  if (!mounted) return;

  setState(() {
    shops = mapped;
    loading = false;
  });
}
  // --------------------------------------------------
  // SAVE ORDER (reorder API call)
  // --------------------------------------------------
  Future<void> saveOrder() async {
    final salesmanIdToUse =
        role == "salesman" ? widget.user["user_id"].toString() : selectedSalesmanId;

    if (salesmanIdToUse == null) return;

    final ok = await ApiService.reorderAssignedShops(
      salesmanIdToUse,
      shops.map<String>((e) => e["sk"].toString()).toList(),
    );

    if (!mounted) return;

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

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? "Removed ✅" : "Remove Failed ❌"),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );

    if (ok) loadAssignedForSalesman(salesmanIdToUse);
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = role == "manager" || role == "master";

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
          // HEADER
          Container(
            height: 230,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF002D62), Color(0xFF005BBB)],
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

                  // ✅ DROPDOWN (only manager/master)
                  if (canEdit)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                          final id = u["user_id"].toString();
                          final name = (u["name"] ?? "").toString();
                          final seg = (u["segment"] ?? "").toString();
                          return DropdownMenuItem(
                            value: id,
                            child: Text("$name ($seg)"),
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
                                    style: TextStyle(fontSize: 16, color: Colors.black54),
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
                                      : (a, b) {}, // salesman -> no reorder
                                  itemBuilder: (context, i) {
                                    return _shopCard(shops[i], i, canEdit);
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
  // SHOP CARD UI
  // --------------------------------------------------
  Widget _shopCard(Map<String, dynamic> shop, int i, bool canEdit) {
    return Container(
      key: ValueKey(shop["_id"]),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF005BBB).withOpacity(0.08)),
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
          // Sequence badge
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF002D62), Color(0xFF005BBB)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                "${i + 1}",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Shop info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (shop["shop_name"] ?? "").toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Segment: ${(shop["segment"] ?? "").toString()}",
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 3),
                Text(
                  (shop["address"] ?? "").toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),

          // Delete + Drag
          if (canEdit) ...[
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteAssignedShop(shop["sk"].toString()),
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