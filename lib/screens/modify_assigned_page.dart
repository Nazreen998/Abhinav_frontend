import 'package:flutter/material.dart';
import '../services/api_service.dart' as api;
import '../services/auth_service.dart';

class ModifyAssignedPage extends StatefulWidget {
  final String salesmanId;
  final List currentShops;

  const ModifyAssignedPage({
    super.key,
    required this.salesmanId,
    required this.currentShops,
  });

  @override
  State<ModifyAssignedPage> createState() => _ModifyAssignedPageState();
}

class _ModifyAssignedPageState extends State<ModifyAssignedPage> {
  List allShops = [];        // All shops allowed for assign
  List selected = [];        // Selected shop IDs
  bool loading = true;

  String role = "";
  String segment = "";

  @override
  @override
void initState() {
  super.initState();

  selected = widget.currentShops.map((e) => e["shopId"]).toList();

  final user = AuthService.currentUser!;
  role = user["role"]?.toString().toLowerCase() ?? "";
  segment = user["segment"]?.toString().toLowerCase() ?? "";

  loadShops();
}

  // ------------------------------------------
  // LOAD SHOPS (Role Based)
  // ------------------------------------------
  Future<void> loadShops() async {
    setState(() => loading = true);

      allShops = await api.ApiService.getShops();

    setState(() => loading = false);
  }

  // ------------------------------------------
  // SAVE CHANGES (Remove old + Add new)
  // ------------------------------------------
Future<void> saveChanges() async {
  // REMOVE unchecked
  for (var old in widget.currentShops) {
    if (!selected.contains(old["_id"])) {
      await api.ApiService.removeAssignedShop(old["_id"]);
    }
  }

  // ADD newly checked
  for (var shop in allShops) {
    if (selected.contains(shop["_id"])) {
      final exists = widget.currentShops
          .any((e) => e["shop_name"] == shop["shop_name"]);

      if (!exists) {
        await api.ApiService.assignShop(
          shop["shop_name"],
          widget.salesmanId,
          shop["segment"],
        );
      }
    }
  }

  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Assigned Shops Updated Successfully"),
      backgroundColor: Colors.green,
    ),
  );

  Navigator.pop(context, true);
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007BFF), Color(0xFF66B2FF), Color(0xFFB8E0FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Modify Assigned Shops",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: allShops.length,
                                itemBuilder: (_, i) {
                                  final shop = allShops[i];
                                  final shopId = shop["shopId"];
                                  final shopName = shop["shopName"];

                                  bool isSelected = selected.contains(shopId);

                                  return Card(
                                    elevation: 4,
                                    margin:
                                        const EdgeInsets.only(bottom: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18),
                                    ),
                                    child: CheckboxListTile(
                                      activeColor: Colors.blueAccent,
                                      title: Text(
                                        shopName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle:
                                          Text(shop["address"] ?? ""),
                                      value: isSelected,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            selected.add(shopId);
                                          } else {
                                            selected.remove(shopId);
                                          }
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: saveChanges,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  "Save Changes",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
