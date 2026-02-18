// ignore_for_file: avoid_print, unused_import

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
  List<dynamic> allShops = [];
  List<String> selectedShopIds = [];
  late String salesmanName; 
  bool loading = true;

 @override
void initState() {
  super.initState();

  salesmanName = widget.currentShops.isNotEmpty
      ? widget.currentShops.first["salesman_name"]?.toString() ?? ""
      : "";

  selectedShopIds = widget.currentShops
      .map<String>((e) => e["shop_id"]?.toString() ?? "")
      .where((e) => e.isNotEmpty)
      .toList();

  loadShops();
}
  // --------------------------------------------------
  // LOAD SHOPS
  // --------------------------------------------------
  Future<void> loadShops() async {
    setState(() => loading = true);

    try {
      allShops = await api.ApiService.getShops();
    } catch (e) {
      print("❌ Load shops error: $e");
      allShops = [];
    }

    setState(() => loading = false);
  }

  // --------------------------------------------------
  // SAVE CHANGES
  // --------------------------------------------------
  Future<void> saveChanges() async {
    /// REMOVE unchecked shops
    for (var old in widget.currentShops) {
      final oldShopId = old["shop_id"]?.toString() ?? "";
      if (oldShopId.isNotEmpty && !selectedShopIds.contains(oldShopId)) {
        await api.ApiService.removeAssignedShop(old["_id"]);
      }
    }

    /// ADD newly checked shops
    for (var shop in allShops) {
      final shopId = shop["shop_id"]?.toString() ?? "";
      final shopName = shop["shop_name"]?.toString() ?? "";
      final shopSegment = shop["segment"]?.toString() ?? "";

      if (shopId.isEmpty || shopName.isEmpty) continue;

      final alreadyExists = widget.currentShops.any(
        (e) => e["shop_id"]?.toString() == shopId,
      );

      if (selectedShopIds.contains(shopId) && !alreadyExists) {
        await api.ApiService.assignShop(
          shopName,
          salesmanName,
          shopSegment,
        );
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

  // --------------------------------------------------
  // UI
  // --------------------------------------------------
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
              // HEADER
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

                                  final shopId =
                                      shop["shop_id"]?.toString() ?? "";
                                  if (shopId.isEmpty) return const SizedBox();

                                  final shopName =
                                      shop["shop_name"]?.toString() ??
                                          "Unnamed Shop";
                                  final address =
                                      shop["address"]?.toString() ?? "";

                                  final isSelected =
                                      selectedShopIds.contains(shopId);

                                  return Card(
                                    elevation: 3,
                                    margin:
                                        const EdgeInsets.only(bottom: 10),
                                    child: CheckboxListTile(
                                      value: isSelected,
                                      activeColor: Colors.blue,
                                      title: Text(
                                        shopName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(address),
                                      onChanged: (v) {
                                        setState(() {
                                          if (v == true) {
                                            selectedShopIds.add(shopId);
                                          } else {
                                            selectedShopIds.remove(shopId);
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
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  "Save Changes",
                                  style: TextStyle(
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
