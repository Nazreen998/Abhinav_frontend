import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AssignedShopsScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const AssignedShopsScreen({super.key, required this.user});

  @override
  State<AssignedShopsScreen> createState() => _AssignedShopsScreenState();
}

class _AssignedShopsScreenState extends State<AssignedShopsScreen> {
  List<dynamic> shops = [];
  bool loading = true;
  String search = "";

  @override
  void initState() {
    super.initState();
    loadAssignedShops();
  }

  // ⭐ FETCH + MAP BACKEND DATA CORRECTLY
  Future<void> loadAssignedShops() async {
    setState(() => loading = true);

    final userId = widget.user["user_id"];
    final role = widget.user["role"].toString().toLowerCase();

    // BACKEND CALL
    final raw = await ApiService.getAssignedShops("", "", userId);

    // MAP DATA TO UI FORMAT
    final List mapped = raw.map((a) {
      final shop = a["shopId"] ?? {};
      final man = a["salesman"] ?? {};

      return {
        "shopName": shop["shop_name"] ?? "",
        "address": shop["address"] ?? "",
        "segment": shop["segment"] ?? "",
        "salesmanName": man["name"] ?? "",
        "shopId": shop["_id"] ?? shop["shop_id"] ?? "",
        "salesmanId": man["_id"] ?? "",
      };
    }).toList();

    setState(() {
      shops = mapped;
      loading = false;
    });
  }

  // ⭐ DELETE ASSIGNMENT — ONLY MASTER & MANAGER CAN DO THIS
  Future<void> deleteAssignment(String shopId, String salesmanId) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Remove Assigned Shop"),
        content: const Text("Are you sure you want to remove this assignment?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete")),
        ],
      ),
    );

    if (confirm != true) return;

    final res =
        await ApiService.removeAssignedShop(shopId, salesmanId);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(res["message"] ?? "Deleted")));

    loadAssignedShops();
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.user["role"].toString().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Shops"),
        actions: [
          IconButton(onPressed: loadAssignedShops, icon: const Icon(Icons.refresh))
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : shops.isEmpty
              ? const Center(child: Text("No assigned shops"))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        onChanged: (v) => setState(() => search = v),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: "Search shop...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: buildList(role)),
                  ],
                ),
    );
  }

  // ⭐ LIST UI
  Widget buildList(String role) {
    final filtered = shops.where((s) {
      return s["shopName"]
          .toString()
          .toLowerCase()
          .contains(search.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final shop = filtered[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(
              shop["shopName"],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Address: ${shop["address"]}"),
                Text("Segment: ${shop["segment"]}"),
                if (role != "salesman")
                  Text("Salesman: ${shop["salesmanName"]}"),
              ],
            ),

            // ⭐ ONLY MASTER & MANAGER SEE DELETE BUTTON
            trailing: (role == "master" || role == "manager")
                ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteAssignment(
                      shop["shopId"],
                      shop["salesmanId"],
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
