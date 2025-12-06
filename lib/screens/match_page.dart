// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:math';
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

  String? previewImageBase64;
  String? uploadedPhotoUrl;
  double? userLat;
  double? userLng;
  double? distanceDiff;

  // ---------------------------------------
  // Haversine distance formula
  // ---------------------------------------
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

  // ---------------------------------------
  // CAPTURE + LIVE GPS + UPLOAD + MATCH
  // ---------------------------------------
  Future<void> captureAndMatch() async {
    setState(() => processing = true);

    // 1️⃣ Capture image
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.camera);
    if (img == null) {
      setState(() => processing = false);
      return;
    }

    // Convert to base64
    final bytes = await img.readAsBytes();
    previewImageBase64 = base64Encode(bytes);

    // 2️⃣ GET LIVE GPS (works on Android + Web)
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    userLat = pos.latitude;
    userLng = pos.longitude;

    // 3️⃣ Upload image
    uploadedPhotoUrl = await visitService.uploadPhoto(
      previewImageBase64!,
      "visit_${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    // 4️⃣ Compare distance
    double shopLat = double.tryParse(widget.shop["lat"].toString()) ?? 0.0;
    double shopLng = double.tryParse(widget.shop["lng"].toString()) ?? 0.0;

    distanceDiff = calcDistance(shopLat, shopLng, userLat!, userLng!);

    String result = distanceDiff! <= 50 ? "match" : "mismatch";

    // 5️⃣ Save visit
    final payload = {
      "salesman_id": AuthService.currentUser!["user_id"],
      "shop_id": widget.shop["shop_id"],
      "lat": userLat,
      "lng": userLng,
      "photo_url": uploadedPhotoUrl ?? "",
    };

    await visitService.visitShop(payload);

    // 6️⃣ Show success/fail
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result == "match"
              ? "MATCH ✔ (within 50 meters)"
              : "MISMATCH ❌ (outside 50 meters)",
        ),
        backgroundColor: result == "match" ? Colors.green : Colors.red,
      ),
    );

    Navigator.pop(context, true);
    setState(() => processing = false);
  }

  // ---------------------------------------
  // UI
  // ---------------------------------------
  @override
  Widget build(BuildContext context) {
    final s = widget.shop;

    return Scaffold(
      appBar: AppBar(title: const Text("Match Shop")),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            Text(
              s["shop_name"],
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(s["address"] ?? ""),
            Text("Lat: ${s["lat"]}, Lng: ${s["lng"]}"),

            const SizedBox(height: 20),

            if (previewImageBase64 != null)
              Container(
                height: 250,
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: MemoryImage(base64Decode(previewImageBase64!)),
                  ),
                ),
              ),

            if (distanceDiff != null)
              Text(
                "Distance: ${distanceDiff!.toStringAsFixed(1)} meters",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: processing ? null : captureAndMatch,
              icon: const Icon(Icons.camera_alt),
              label: Text(
                processing ? "Processing..." : "Capture & Match",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
