// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import '../services/auth_service.dart';
import '../services/visit_service.dart';

class MatchPage extends StatefulWidget {
  final dynamic shop;

  const MatchPage({super.key, required this.shop});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  final VisitService visitService = VisitService();

  bool processing = false;
  String? previewBase64;
  String? uploadedUrl;

  double? distanceMeters;
  double? userLat;
  double? userLng;

  // ---------------------------
  // Distance Calculation
  // ---------------------------
  double calcDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);

    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  // ---------------------------
  // CAPTURE → GPS → UPLOAD → SAVE
  // ---------------------------
  Future<void> captureAndMatch() async {
  setState(() => processing = true);

  Position pos = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  userLat = pos.latitude;
  userLng = pos.longitude;

  double shopLat = double.tryParse(widget.shop["lat"].toString()) ?? 0.0;
  double shopLng = double.tryParse(widget.shop["lng"].toString()) ?? 0.0;

  distanceMeters = calcDistance(userLat!, userLng!, shopLat, shopLng);
  bool isMatch = distanceMeters! <= 50;

  // 🔥 FINAL PAYLOAD (NO EXTRA FIELDS)
  final payload = {
    "shop_id": widget.shop["shop_id"],   // ✅ ONLY shop_id
    "shop_name": widget.shop["shop_name"],
    "result": isMatch ? "match" : "mismatch",
  };

  await visitService.visitShop(payload);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        isMatch
            ? "MATCH ✔ Within 50 meters"
            : "MISMATCH ❌ Too far from shop",
      ),
      backgroundColor: isMatch ? Colors.green : Colors.red,
    ),
  );

  Navigator.pop(context, true);
  setState(() => processing = false);
}

  // ---------------------------
  // UI
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    final s = widget.shop;

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
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 28),
                  ),
                  const Text(
                    "Match Shop",
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s["shop_name"],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(s["address"] ?? ""),
                    Text("Lat: ${s["lat"]}, Lng: ${s["lng"]}"),
                  ],
                ),
              ),

              if (previewBase64 != null)
                Container(
                  height: 250,
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    image: DecorationImage(
                      image: MemoryImage(base64Decode(previewBase64!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              if (distanceMeters != null)
                Text(
                  "Distance: ${distanceMeters!.toStringAsFixed(1)} m",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: processing ? null : captureAndMatch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: Text(processing ? "Processing..." : "Capture & Match"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
