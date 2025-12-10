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

  // ⭐ FETCH ASSIGNED SHOPS CORRECTLY
  Future<void> loadAssignedShops() async {
    setState(() => loading = true);

    final userId = widget.user["user_id"];

    // 🔥 CALL CORRECT API
    final raw = await ApiService.getAssignedShops(userId);

    // 🔥 Backend returns this format:
    // {
    //   user_id: "ABHI001",
    //   shop_id: "S001",
    //   sequence: 2,
    //   assigned_at: "2025-12-09"
    // }

    // ⭐ MAP TO UI FORMAT
   final List mapped = raw.map((s) {
  return {
    "shopId": s["shop_id"] ?? "",
    "shopName": s["shop_name"] ?? "",
    "address": s["address"] ?? "",
    "segment": s["segment"] ?? "",
    "salesmanId": s["salesman_id"] ?? "",
    "salesmanName": s["salesman_name"] ?? "",
  };
}).toList();

    setState(() {
      shops = mapped;
      loading = false;
    });
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
      return s["shopId"]
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
              "Shop ID: ${shop["shopId"]}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Sequence: ${shop["sequence"]}"),

            // ⭐ Only master/manager see delete button (if enabled in backend)
            trailing: (role == "master" || role == "manager")
                ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Delete option later
                    },
                  )
                : null,
          ),
        );
      },
    );
  }
}
