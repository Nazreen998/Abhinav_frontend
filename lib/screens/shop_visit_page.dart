import 'package:flutter/material.dart';
import '../services/log_service.dart';
import '../models/log_model.dart';
import '../models/shop_model.dart';
import '../services/auth_service.dart';

class ShopVisitPage extends StatefulWidget {
  final ShopModel shop;
  const ShopVisitPage({super.key, required this.shop});

  @override
  State<ShopVisitPage> createState() => _ShopVisitPageState();
}

class _ShopVisitPageState extends State<ShopVisitPage> {
  final logService = LogService();
  bool loading = false;

  Future<void> saveVisit() async {
    setState(() => loading = true);

    final user = AuthService.currentUser!;
    final now = DateTime.now();

    LogModel log = LogModel(
    userId: user["user_id"].toString(),
    shopId: widget.shop.shopId.toString(),
    shopName: widget.shop.shopName,
    salesman: user["name"].toString(),           // NEW
    date: "${now.day}-${now.month}-${now.year}",
    time: "${now.hour}:${now.minute}",
    lat: widget.shop.lat,                        // double
    lng: widget.shop.lng,                        // double
    distance: 0.0,                               // first time 0, backend real distance
    result: "Visited",
    segment: widget.shop.segment,
    photoUrl: "",                                // photo upload empty string
  );

    await logService.addLog(log.toJson());
    setState(() => loading = false);

    Navigator.pop(context);
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
              // 🔙 BACK + TITLE
              Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back, size: 28, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.shop.shopName,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // MAIN CARD
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(18),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Shop Address",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 8),
                      Text(
                        widget.shop.address,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            "Lat: ${widget.shop.lat} | Lng: ${widget.shop.lng}",
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      loading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: saveVisit,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15),
                                  backgroundColor: const Color(0xFF0066CC),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  "Mark as Visited",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
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
