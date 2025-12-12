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

  // --------------------------------------------------
  // LOAD ASSIGNED SHOPS
  // --------------------------------------------------
  Future<void> loadAssignedShops() async {
    setState(() => loading = true);

    final userId = widget.user["user_id"];

    final assigned = await ApiService.getAssignedShops();
    final allShops = await ApiService.getShops();

    final userAssigned =
        assigned.where((a) => a["user_id"] == userId).toList();

    final mapped = userAssigned.map((a) {
      final match = allShops.firstWhere(
        (s) => s["shop_id"] == a["shop_id"],
        orElse: () => {},
      );

      return {
        "shop_id": a["shop_id"],
        "shop_name": match["shop_name"] ?? "Unknown Shop",
        "address": match["address"] ?? "",
        "segment": match["segment"] ?? "",
        "sequence": a["sequence"] ?? 0,
      };
    }).toList();

    mapped.sort((a, b) => a["sequence"].compareTo(b["sequence"]));

    setState(() {
      shops = mapped;
      loading = false;
    });
  }

  // --------------------------------------------------
  // SAVE ORDER TO SERVER
  // --------------------------------------------------
  Future<void> saveOrder() async {
    if (shops.isEmpty) return;

    final payload = {
      "salesman_name": widget.user["name"],
      "shops": List.generate(
        shops.length,
        (i) => {
          "shop_name": shops[i]["shop_name"],
          "sequence": i + 1,
        },
      ),
    };

    final ok = await ApiService.reorderAssignedShops(payload);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? "Order Updated Successfully"
            : "Order Update Failed"),
      ),
    );

    if (ok) loadAssignedShops();
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.user["role"].toString().toLowerCase();

    final visible = shops
        .where((s) =>
            s["shop_name"].toLowerCase().contains(search.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Shops"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadAssignedShops,
          ),
          if (role == "master" || role == "manager")
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: saveOrder,
            ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : visible.isEmpty
              ? const Center(child: Text("No assigned shops"))
              : ReorderableListView.builder(
                  itemCount: visible.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;

                      final moved = shops.removeAt(oldIndex);
                      shops.insert(newIndex, moved);
                    });
                  },
                  itemBuilder: (_, i) {
                    final shop = visible[i];
                    return Card(
                      key: ValueKey(shop["shop_id"]),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text("${i + 1}"),
                        ),
                        title: Text(
                          shop["shop_name"],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Sequence: ${i + 1}"),
                        trailing: (role == "master" || role == "manager")
                            ? const Icon(Icons.drag_handle)
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}
