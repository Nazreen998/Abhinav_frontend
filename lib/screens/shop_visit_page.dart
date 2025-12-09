import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  File? selectedImage;

  final ImagePicker picker = ImagePicker();

  // ------------------------------
  // PICK IMAGE FROM CAMERA
  // ------------------------------
  Future pickFromCamera() async {
    final XFile? img = await picker.pickImage(source: ImageSource.camera);
    if (img != null) {
      setState(() => selectedImage = File(img.path));
    }
  }

  // ------------------------------
  // PICK IMAGE FROM GALLERY
  // ------------------------------
  Future pickFromGallery() async {
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => selectedImage = File(img.path));
    }
  }

  // ------------------------------
  // SAVE VISIT LOG
  // ------------------------------
  Future<void> saveVisit() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please take a photo before submitting")),
      );
      return;
    }

    setState(() => loading = true);

    final user = AuthService.currentUser!;
    final now = DateTime.now();

    // ---------------------------------------------
    // Create date & time strings
    // ---------------------------------------------
    final dateStr =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    // ---------------------------------------------
    // Upload image to backend
    // ---------------------------------------------
    final bytes = await selectedImage!.readAsBytes();
    final base64Image = base64Encode(bytes);

    final uploadedUrl = await logService.uploadPhoto(
      base64Image,
      "visit_${now.millisecondsSinceEpoch}.jpg",
    );

    if (uploadedUrl == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Photo upload failed")));
      setState(() => loading = false);
      return;
    }

    // ---------------------------------------------
    // Create Log Model (FULL CORRECT DATA)
    // ---------------------------------------------
    LogModel log = LogModel(
      userId: user["user_id"],
      shopId: widget.shop.shopId,
      shopName: widget.shop.shopName,
      salesman: user["name"],
      date: dateStr,
      time: timeStr,
      datetime: now.toIso8601String(),
      lat: widget.shop.lat, // (Replace with GPS later if needed)
      lng: widget.shop.lng,
      distance: 0.0,
      result: "match", // result MUST BE match/mismatch
      segment: widget.shop.segment.toLowerCase(),
      photoUrl: uploadedUrl,
    );

    // ---------------------------------------------
    // SEND TO SERVER
    // ---------------------------------------------
    final ok = await logService.saveVisit(log);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Visit saved successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save visit")),
      );
    }

    setState(() => loading = false);
    Navigator.pop(context);
  }

  // ------------------------------
  // UI SECTION
  // ------------------------------
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
              // ------------------- HEADER -------------------
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        size: 28, color: Colors.white),
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

              // ------------------- BODY -------------------
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      // -------------- PHOTO PREVIEW --------------
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade200,
                          image: selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: selectedImage == null
                            ? const Center(
                                child: Text(
                                  "No photo selected",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              )
                            : null,
                      ),

                      const SizedBox(height: 15),

                      // -------------- CAMERA / GALLERY BUTTONS --------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: pickFromCamera,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text("Camera"),
                          ),
                          ElevatedButton.icon(
                            onPressed: pickFromGallery,
                            icon: const Icon(Icons.photo),
                            label: const Text("Gallery"),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // -------------- SUBMIT LOG BUTTON --------------
                      loading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: saveVisit,
                                child: const Text("Submit Visit"),
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
