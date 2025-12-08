import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'modify_assigned_page.dart';

class AssignedShopsScreen extends StatefulWidget {
  final String userId;

  const AssignedShopsScreen({super.key, required this.userId});

  @override
  State<AssignedShopsScreen> createState() => _AssignedShopsScreenState();
}

class _AssignedShopsScreenState extends State<AssignedShopsScreen> {
  List assigned = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAssigned();
  }
  Future<void> loadAssigned() async {
  if (!mounted) return;
  setState(() => loading = true);

  final result = await ApiService.fetchAssignedShops(widget.userId);

  if (!mounted) return;
  assigned = result;
  loading = false;

  if (mounted) setState(() {});
}

  Future<void> removeShop(String shopId) async {
    bool ok = await ApiService.unassignShop(widget.userId, shopId);
    if (ok) loadAssigned();
  }

  Future<void> deleteAll() async {
    for (var shop in assigned) {
      await ApiService.unassignShop(widget.userId, shop["shop_id"]);
    }
    loadAssigned();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text("Assigned Shops"),
        actions: [
          if (assigned.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.white),
              onPressed: deleteAll,
            )
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : assigned.isEmpty
              ? const Center(child: Text("No shops assigned"))
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF007BFF), Color(0xFF66B2FF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: assigned.length,
                    itemBuilder: (context, index) {
                      final s = assigned[index];

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.only(bottom: 14),
                        child: ListTile(
                          title: Text(
                            (s["shop_name"] ?? "Unknown Shop"),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
  "Segment: ${(s["segment"] ?? "N/A")}\n"
  "Sequence: ${s["sequence"] ?? '-'}",
),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.blueAccent),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ModifyAssignedPage(
                                        userId: widget.userId,
                                        currentShops: assigned,
                                      ),
                                    ),
                                  ).then((_) => loadAssigned());
                                },
                              ),

                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () => removeShop(s["shop_id"]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
