import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ModifyAssignedPage extends StatefulWidget {
  final String userId;
  final List currentShops;

  const ModifyAssignedPage({
    super.key,
    required this.userId,
    required this.currentShops,
  });

  @override
  State<ModifyAssignedPage> createState() => _ModifyAssignedPageState();
}

class _ModifyAssignedPageState extends State<ModifyAssignedPage> {
  List allShops = [];
  List selected = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    selected = widget.currentShops.map((e) => e["shop_id"]).toList();
    loadAllShops();
  }

  Future<void> loadAllShops() async {
    allShops = await ApiService.getAllShops();
    loading = false;
    setState(() {});
  }

  Future<void> saveChanges() async {
    bool ok = await ApiService.assignShops(widget.userId, selected);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Assigned Shops Updated Successfully"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF007BFF),
              Color(0xFF66B2FF),
              Color(0xFFB8E0FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 🔹 Top Bar
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

              // WHITE CONTAINER
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            const SizedBox(height: 10),

                            Expanded(
                              child: ListView.builder(
                                itemCount: allShops.length,
                                itemBuilder: (_, i) {
                                  final shop = allShops[i];
                                  bool isSelected =
                                      selected.contains(shop["shop_id"]);

                                  return Card(
                                    elevation: 4,
                                    margin:
                                        const EdgeInsets.only(bottom: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: CheckboxListTile(
                                      activeColor: Colors.blueAccent,
                                      title: Text(
                                        shop["shop_name"],
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
                                            selected.add(shop["shop_id"]);
                                          } else {
                                            selected.remove(shop["shop_id"]);
                                          }
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 🔹 Save Button
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
