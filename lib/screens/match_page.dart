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
  final dynamic shop; // Map shop data from assigned list

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
  // Distance Calculation (meters)
  // ---------------------------
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

  // ---------------------------
  // CAPTURE → GPS → MATCH
  // ---------------------------
  Future<void> captureAndMatch() async {
    setState(() => processing = true);

    final picker = ImagePicker();
    XFile? img;

    // Web / Laptop → gallery only
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      img = await picker.pickImage(source: ImageSource.gallery);
    } else {
      img = await picker.pickImage(source: ImageSource.camera);
    }

    if (img == null) {
      setState(() => processing = false);
      return;
    }

    // IMAGE → BASE64
    final bytes = await img.readAsBytes();
    previewBase64 = base64Encode(bytes);

    // GET LIVE GPS
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    userLat = pos.latitude;
    userLng = pos.longitude;

    // UPLOAD PHOTO
    uploadedUrl = await visitService.uploadPhoto(
      previewBase64!,
      "visit_${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    // CALCULATE DISTANCE
    double shopLat = double.tryParse(widget.shop["lat"].toString()) ?? 0.0;
    double shopLng = double.tryParse(widget.shop["lng"].toString()) ?? 0.0;

    distanceMeters = calcDistance(userLat!, userLng!, shopLat, shopLng);

    bool isMatch = distanceMeters! <= 50;

    // SEND VISIT TO BACKEND (NEW FORMAT)
    final payload = {
      "salesman_id": AuthService.currentUser!["user_id"],
      "shop_id": widget.shop["shop_id"],
      "shop_name": widget.shop["shop_name"],
      "photo_url": uploadedUrl ?? "",
      "lat": userLat,
      "lng": userLng,
      "distance": distanceMeters!.toStringAsFixed(1),
      "match": isMatch ? "match" : "mismatch",
      "segment": widget.shop["segment"] ?? "",
    };

    await visitService.visitShop(payload);

    // SHOW RESULT
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
        width: double.infinity,
        height: double.infinity,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BACK BUTTON + TITLE
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

              // SHOP DETAILS CARD
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s["shop_name"],
                      style: const TextStyle(
                        color: Color(0xFF003366),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s["address"] ?? "",
                      style: const TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                    const SizedBox(height: 5),
                    Text("Lat: ${s["lat"]}, Lng: ${s["lng"]}"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // PHOTO PREVIEW
              if (previewBase64 != null)
                Container(
                  height: 250,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    image: DecorationImage(
                      image: MemoryImage(base64Decode(previewBase64!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // DISTANCE DISPLAY
              if (distanceMeters != null)
                Center(
                  child: Text(
                    "Distance: ${distanceMeters!.toStringAsFixed(1)} meters",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 25),

              // MATCH BUTTON
              Center(
                child: ElevatedButton(
                  onPressed: processing ? null : captureAndMatch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 45, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    processing ? "Processing..." : "Capture & Match",
                    style: const TextStyle(fontSize: 17),
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
