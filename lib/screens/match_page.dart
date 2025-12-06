// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../helpers/exif_helper.dart';
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
  double? photoLat;
  double? photoLng;
  double? distanceDiff;

  // -----------------------------------------------
  // HAVERSINE DISTANCE (meters)
  // -----------------------------------------------
  double calcDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // meters
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);

    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  // -----------------------------------------------
  // CAPTURE → GPS → UPLOAD → MATCH → SAVE VISIT
  // -----------------------------------------------
  Future<void> captureAndMatch() async {
    setState(() => processing = true);

    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.camera);

    if (img == null) {
      setState(() => processing = false);
      return;
    }

    // Convert to base64
    final bytes = await img.readAsBytes();
    previewImageBase64 = base64Encode(bytes);

    // Extract EXIF GPS
    final gps = ExifHelper.extractGPS(bytes);
    photoLat = gps["lat"];
    photoLng = gps["lng"];

    if (photoLat == null || photoLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ No GPS found in this photo. Enable Location in Camera."),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => processing = false);
      return;
    }

    // Upload image to backend
    uploadedPhotoUrl = await visitService.uploadPhoto(
      previewImageBase64!,
      "visit_${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    // Shop location
    double shopLat = double.tryParse(widget.shop["lat"].toString()) ?? 0.0;
    double shopLng = double.tryParse(widget.shop["lng"].toString()) ?? 0.0;

    // Calculate meters
    distanceDiff = calcDistance(shopLat, shopLng, photoLat!, photoLng!);

    // 50 meters threshold
    String result = distanceDiff! <= 50 ? "match" : "mismatch";

    // VISIT PAYLOAD
    final payload = {
      "salesman_id": AuthService.currentUser!["user_id"],
      "shop_id": widget.shop["shop_id"],
      "lat": photoLat,
      "lng": photoLng,
      "photo_url": uploadedPhotoUrl ?? "",
    };

    await visitService.visitShop(payload);

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

  // -----------------------------------------------
  // BUILD UI
  // -----------------------------------------------
  @override
  Widget build(BuildContext context) {
    final s = widget.shop;

    // ❌ Web cannot capture GPS from image → Show warning
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text("Match Shop")),
        body: const Center(
          child: Text(
            "❌ MATCH feature is not supported on Web.\nPlease use Android mobile app.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Colors.red),
          ),
        ),
      );
    }

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
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        size: 28, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Match Shop",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // -------------------------
              // SHOP CARD
              // -------------------------
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      s["shop_name"],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      s["address"] ?? "",
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Text("Lat: ${s["lat"]}   Lng: ${s["lng"]}"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // PHOTO PREVIEW
              if (previewImageBase64 != null)
                Container(
                  height: 260,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: MemoryImage(base64Decode(previewImageBase64!)),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // DISTANCE DISPLAY
              if (distanceDiff != null)
                Text(
                  "Distance: ${distanceDiff!.toStringAsFixed(1)} meters",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),

              const SizedBox(height: 20),

              // CAPTURE BUTTON
              ElevatedButton.icon(
                onPressed: processing ? null : captureAndMatch,
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  processing ? "Processing..." : "Capture & Match",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
