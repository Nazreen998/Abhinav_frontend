// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
// ignore: unused_import
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../services/auth_service.dart';
import '../helpers/location_helper.dart';

import '../helpers/web_camera_stub.dart'
    if (dart.library.html) '../helpers/web_camera_helper.dart';

import '../helpers/web_location_helper_stub.dart'
    if (dart.library.html) '../helpers/web_location_helper.dart';

import 'package:http/http.dart' as http;

class AddShopPage extends StatefulWidget {
  const AddShopPage({super.key});

  @override
  State<AddShopPage> createState() => _AddShopPageState();
}

class _AddShopPageState extends State<AddShopPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  File? imageFile;
  String? base64Image;

  double? lat;
  double? lng;

  bool loading = false;

  // ==========================================
  // PICK PHOTO POPUP
  // ==========================================
  Future pickPhoto() async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () async {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose File / Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // CAMERA PICK (WEB + MOBILE)
  // ==========================================
  Future _pickFromCamera() async {
    if (kIsWeb) {
      bool hasCam = await WebCameraHelper.hasWebCamera();
      if (!hasCam) {
        _error("No Camera Detected");
        return;
      }

      WebCameraHelper.pickFromCamera((base64) {
        setState(() => base64Image = base64);
        getLocation();
      });

      return;
    }

    // MOBILE CAMERA
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      imageFile = File(picked.path);
      base64Image = base64Encode(await imageFile!.readAsBytes());
      setState(() {});
      getLocation();
    }
  }

  // ==========================================
  // GALLERY PICK (WEB + MOBILE)
  // ==========================================
  Future _pickFromGallery() async {
    if (kIsWeb) {
      final result = await FilePicker.platform
          .pickFiles(type: FileType.image, withData: true);
      if (result != null) {
        base64Image = base64Encode(result.files.single.bytes!);
        imageFile = null;
        setState(() {});
        getLocation();
      }
      return;
    }

    if (Platform.isWindows) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) {
        imageFile = File(result.files.single.path!);
        base64Image = base64Encode(await imageFile!.readAsBytes());
        setState(() {});
        getLocation();
      }
      return;
    }

    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imageFile = File(picked.path);
      base64Image = base64Encode(await imageFile!.readAsBytes());
      setState(() {});
      getLocation();
    }
  }

  // ==========================================
  // GET LOCATION
  // ==========================================
  Future getLocation() async {
    if (kIsWeb) {
      final blocked = await WebLocationHelper.isLocationBlocked();
      if (blocked) {
        WebLocationHelper.showLocationBlockedDialog(context);
        return;
      }
    }

    final pos = await LocationHelper.getLocation();
    if (pos == null) {
      _error("Enable location permission");
      return;
    }

    lat = pos.latitude;
    lng = pos.longitude;

    setState(() {});
  }

  // ==========================================
  // SUBMIT SHOP → SEND TO PENDING SHOPS
  // ==========================================
  Future submit() async {
    // ================= DEBUG POPUP =================
    void debugBox(String msg) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("DEBUG"),
          content: SingleChildScrollView(child: Text(msg)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    }

    // ================= BASIC VALIDATION =================
    if (nameController.text.isEmpty) return _error("Enter shop name");
    if (addressController.text.isEmpty) return _error("Enter address");
    if (base64Image == null) return _error("Select a photo");
    if (lat == null || lng == null) return _error("Location not detected");

    // ================= TOKEN CHECK (🔥 MAIN FIX) =================
    if (AuthService.token == null) {
      debugBox("TOKEN NOT READY ❌\nWait 2 seconds and try again");
      return;
    }

    final payload = {
      "shop_name": nameController.text.trim(),
      "address": addressController.text.trim(),
      "lat": lat,
      "lng": lng,
      "segment": "pipes", // or user segment
      "shopImage": base64Image,
    };

    setState(() => loading = true);

    final url = Uri.parse(
      "https://abhinav-backend.onrender.com/api/shops/add",
    );

    try {
      final res = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${AuthService.token}",
        },
        body: jsonEncode(payload),
      );

      setState(() => loading = false);

      // ================= STATUS CHECK =================
      if (res.statusCode != 200) {
        debugBox(
          "SERVER ERROR ❌\n"
          "Status: ${res.statusCode}\n"
          "Body:\n${res.body}",
        );
        return;
      }

      final data = jsonDecode(res.body);

      if (data["success"] == true) {
        _success("Shop submitted for approval");
        if (mounted) Navigator.pop(context);
      } else {
        _error(data["message"] ?? "Submit failed");
      }
    } catch (e) {
      setState(() => loading = false);
      debugBox("NETWORK / CRASH ERROR ❌\n$e");
    }
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _success(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ==========================================
  // UI
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: Stack(
        children: [
          // ✅ PREMIUM HEADER
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF002D62),
                  Color(0xFF005BBB),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 25),
                  Text(
                    "Add Shop",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ FLOATING WHITE CARD
          Positioned(
            top: 140,
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ListView(
                children: [
                  _input(nameController, "Shop Name"),
                  const SizedBox(height: 18),

                  _input(addressController, "Address"),
                  const SizedBox(height: 20),

                  // 📷 PHOTO BUTTON
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: pickPhoto,
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Take Photo",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF002D62),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  if (base64Image != null) ...[
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        base64Decode(base64Image!),
                        height: 170,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // 📍 LOCATION BADGE
                  if (lat != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Color(0xFF002D62)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Lat: $lat\nLng: $lng",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 28),

                  loading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "Submit for Approval",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
    );
  }

  Widget _input(TextEditingController c, String label) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF4F7FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
