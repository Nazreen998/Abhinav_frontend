import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AssignedShopsScreen extends StatefulWidget {
  final String userId;
  AssignedShopsScreen({required this.userId});

  @override
  _AssignedShopsScreenState createState() => _AssignedShopsScreenState();
}

class _AssignedShopsScreenState extends State<AssignedShopsScreen> {
  
  List shops = [];

  @override
  void initState() {
    super.initState();
    loadShops();
  }

  void loadShops() async {
    shops = await ApiService.fetchAssignedShops(widget.userId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Assigned Shops")),
      body: ListView.builder(
        itemCount: shops.length,
        itemBuilder: (context, index) {
          final shop = shops[index];

          return ListTile(
            title: Text(shop["shopName"]),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                bool done = await ApiService.unassignShop(
                  widget.userId,
                  shop["shopId"],
                );

                if (done) loadShops(); // Refresh list
              },
            ),
          );
        },
      ),
    );
  }
}
