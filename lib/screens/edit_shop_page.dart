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
    nameCtrl = TextEditingController(text: widget.shop["shop_name"]);
    addrCtrl = TextEditingController(text: widget.shop["address"]);
    segment = widget.shop["segment"] ?? "FMCG";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Shop"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Shop Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: addrCtrl,
              decoration: const InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField(
              value: segment,
              items: ["FMCG", "PIPES"]
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => segment = v.toString()),
              decoration: const InputDecoration(
                labelText: "Segment",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: saveShop,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
              ),
              child: const Text(
                "Save Changes",
                style: TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> saveShop() async {
    final updated = {
      "shop_id": widget.shop["shop_id"],
      "shop_name": nameCtrl.text.trim(),
      "address": addrCtrl.text.trim(),
      "segment": segment,
    };

    final ok = await ApiService.updateShop(updated);

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Shop update failed")),
      );
    }
  }
}
