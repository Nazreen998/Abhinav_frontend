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

  String formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return "${dt.day}-${dt.month}-${dt.year}";
    } catch (e) {
      return "";
    }
  }

  Future<void> loadAssignedShops() async {
    setState(() => loading = true);

    final all = await ApiService.getUsers();

    final assigned =
        await ApiService.getAssignedShops(widget.user["user_id"].toString());
    final allShops = await ApiService.getShops();
    print("ASSIGNED COUNT => ${assigned.length}");
    print("ASSIGNED DATA => $assigned");

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
        "salesmanId": a["salesmanId"], // 👈 MUST ADD
        "assignedTo": a["salesmanName"] ?? "",
        "assignedDate": a["createdAt"] ?? "",
        "address": match["address"] ?? a["address"] ?? "",
        "segment": a["segment"] ?? match["segment"] ?? "",
        "sequence": int.tryParse(a["sequence"]?.toString() ?? "0") ?? 0,
      };
    }).toList();

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

  Future<void> _changeAssignmentDate(Map shop) async {
    print("EDIT CLICKED");
    print("SALESMAN ID => ${shop["salesmanId"]}");
    print("OLD SK => ${shop["sk"]}");

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked == null) return;

    final newDate =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

    print("NEW DATE => $newDate");

    final ok = await ApiService.modifyAssignmentDate(
      salesmanId: shop["salesmanId"],
      oldSk: shop["sk"],
      newDate: newDate,
    );

    print("API RESULT => $ok");

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            ok ? "Assignment date updated" : "Failed to update assignment"),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );

    if (ok) loadAssignedShops();
  }

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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 260, // little extra smooth look
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
                      margin: const EdgeInsets.only(top: 20),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔵 Number Badge
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
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 📦 Shop Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shop Name
                Text(
                  shop["shop_name"] ?? "",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),

                const SizedBox(height: 4),

                // Address
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 14, color: Colors.redAccent),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        shop["address"] ?? "",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                // Segment + Assigned To in single row
                Row(
                  children: [
                    const Icon(Icons.category,
                        size: 14, color: Colors.blueGrey),
                    const SizedBox(width: 4),
                    Text(
                      shop["segment"] ?? "",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.person, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        shop["assignedTo"] ?? "",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                // Date
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 12, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      formatDate(shop["assignedDate"]),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ✏️ Edit & 🗑 Delete (Only for manager/master)
          if (role == "manager" || role == "master")
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                  onPressed: () {
                    _changeAssignmentDate(shop);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () {
                    // TODO: Call delete API
                  },
                ),
              ],
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