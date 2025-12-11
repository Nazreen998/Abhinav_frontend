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

  // ⭐ OPTION-1 + OPTION-B
  // Fetch all assigned shops → filter by user → merge with shops list
  Future<void> loadAssignedShops() async {
    if (!mounted) return;
    setState(() => loading = true);

    final userId = widget.user["user_id"];

    // 1️⃣ Get full assigned list
    final assigned = await ApiService.getAssignedShops();

    // 2️⃣ Get all shop details
    final allShops = await ApiService.getShops();

    // 3️⃣ Filter only shops assigned to this user
    final userAssigned = assigned.where((a) => a["user_id"] == userId).toList();

    // 4️⃣ Merge shop details with assigned shops
    final List mapped = userAssigned.map((a) {
      final match = allShops.firstWhere(
        (s) => s["shop_id"] == a["shop_id"],
        orElse: () => {},
      );

      return {
        "shopId": a["shop_id"],
        "sequence": a["sequence"] ?? "",
        "shopName": match["shop_name"] ?? "Unknown Shop",
        "address": match["address"] ?? "",
        "segment": match["segment"] ?? "",
      };
    }).toList();

    if (!mounted) return;
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
          IconButton(
            onPressed: loadAssignedShops,
            icon: const Icon(Icons.refresh),
          ),
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

  // ⭐ LIST UI (unchanged)
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(
              shop["shopName"], // ⭐ Name shows NOW
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Shop ID: ${shop["shopId"]}\n"
              "Sequence: ${shop["sequence"]}",
            ),
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
