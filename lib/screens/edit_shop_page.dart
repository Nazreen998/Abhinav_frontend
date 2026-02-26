// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditShopPage extends StatefulWidget {
  final Map shop;

  const EditShopPage({super.key, required this.shop});

  @override
  State<EditShopPage> createState() => _EditShopPageState();
}

class _EditShopPageState extends State<EditShopPage> {
  late TextEditingController nameCtrl;
  late TextEditingController addrCtrl;

  String segment = "";

  @override
  void initState() {
    super.initState();

    nameCtrl = TextEditingController(
        text: widget.shop["shopName"] ?? widget.shop["shop_name"]);
    addrCtrl = TextEditingController(
        text: widget.shop["shopAddress"] ?? widget.shop["address"]);
    segment = (widget.shop["segment"] ?? "fmcg").toString().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // 🔵 Top Header
            Container(
              height: MediaQuery.of(context).size.height / 3.5,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF002D62),
                    Color(0xFF005BBB),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 45,
                    left: 20,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child:
                            const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                  ),
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store, size: 70, color: Colors.white),
                        SizedBox(height: 10),
                        Text(
                          "Edit Shop",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ⚪ Floating Card
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 4.2,
                left: 20,
                right: 20,
              ),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      _modernInput(
                          controller: nameCtrl,
                          hint: "Shop Name",
                          icon: Icons.store),
                      const SizedBox(height: 20),
                      _modernInput(
                          controller: addrCtrl,
                          hint: "Address",
                          icon: Icons.location_on),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xffececf8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField(
                          value: segment,
                          items: ["FMCG", "PIPES"]
                              .map((s) =>
                                  DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => segment = v.toString()),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.category),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),
                      GestureDetector(
                        onTap: saveShop,
                        child: Container(
                          width: 220,
                          height: 55,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF002D62),
                                Color(0xFF005BBB),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Text(
                              "SAVE CHANGES",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffececf8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  Future<void> saveShop() async {
    final updated = {
      "shop_id": widget.shop["shop_id"], // REAL ID
      "shop_name": nameCtrl.text.trim(),
      "address": addrCtrl.text.trim(),
      "segment": segment.toLowerCase(),
    };

    final ok = await ApiService.updateShop(updated);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Shop updated successfully ✅"),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Shop update failed"), backgroundColor: Colors.red),
      );
    }
  }
}
