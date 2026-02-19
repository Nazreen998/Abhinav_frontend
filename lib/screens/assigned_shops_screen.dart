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

  // --------------------------------------------------
  // LOAD ASSIGNED SHOPS (ROLE BASED)
  // --------------------------------------------------
 Future<void> loadAssignedShops() async {
  setState(() => loading = true);

  final role = widget.user["role"].toString().toLowerCase();
  final mySegment = widget.user["segment"].toString().toLowerCase();

  final assigned = await ApiService.getAssignedShops();

  List filtered = [];

  if (role == "master") {
    filtered = assigned;
  } else if (role == "manager") {
    filtered = assigned
        .where((a) =>
            (a["segment"] ?? "").toString().toLowerCase() == mySegment)
        .toList();
  } else {
    // salesman
    filtered = assigned
        .where((a) =>
            (a["salesmanId"] ?? "").toString() ==
            widget.user["user_id"].toString())
        .toList();
  }

  // sort by sequence
  filtered.sort((a, b) =>
      (a["sequence"] ?? 0).compareTo(b["sequence"] ?? 0));

  if (!mounted) return;

  setState(() {
    shops = filtered;
    loading = false;
  });
}
  // --------------------------------------------------
  // SAVE ORDER (MASTER / MANAGER)
  // --------------------------------------------------
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
      appBar: AppBar(
        title: const Text("Assigned Shops"),
        backgroundColor: Colors.blue,
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
          : shops.isEmpty
              ? const Center(child: Text("No assigned shops"))
              : ReorderableListView.builder(
                  itemCount: shops.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final item = shops.removeAt(oldIndex);
                      shops.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, i) {
                    final shop = shops[i];

                    return Card(
                      key: ValueKey(shop["_id"]),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            "${i + 1}",
                            style:
                                const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          shop["shop_name"],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                            Text("Segment: ${shop["segment"]}"),
                        trailing: (role == "master" ||
                                role == "manager")
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // ✏️ EDIT
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () async {
                                      final updated =
                                          await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                            ModifyAssignedPage(
  salesmanId: widget.user["user_id"],
  salesmanName: widget.user["name"],
  currentShops: shops,
)

                                        ),
                                      );

                                      if (updated == true) {
                                        loadAssignedShops();
                                      }
                                    },
                                  ),

                                  // ❌ REMOVE
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      final ok = await ApiService.removeAssignedShop(
  widget.user["user_id"].toString(),
  shop["sk"].toString(),
);


                                      if (ok) {
                                        loadAssignedShops();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Assigned shop removed"),
                                          ),
                                        );
                                      }
                                    },
                                  ),

                                  const Icon(Icons.drag_handle),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}
