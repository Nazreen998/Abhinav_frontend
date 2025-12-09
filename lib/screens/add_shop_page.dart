import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
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

  // ==========================================================
  // POPUP: CAMERA OR GALLERY
  // ==========================================================
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

  // ==========================================================
  // PICK FROM CAMERA (WEB + MOBILE SAFE)
  // ==========================================================
  Future _pickFromCamera() async {
    if (kIsWeb) {
      bool hasCam = await WebCameraHelper.hasWebCamera();
      if (!hasCam) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No Camera Detected")),
        );
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

  // ==========================================================
  // PICK FROM GALLERY (WEB + MOBILE)
  // ==========================================================
  Future _pickFromGallery() async {
    if (kIsWeb) {
      final result =
          await FilePicker.platform.pickFiles(type: FileType.image, withData: true);

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

    // MOBILE GALLERY
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imageFile = File(picked.path);
      base64Image = base64Encode(await imageFile!.readAsBytes());
      setState(() {});
      getLocation();
    }
  }

  // ==========================================================
  // GET LOCATION (WEB BLOCK CHECK + MOBILE NORMAL)
  // ==========================================================
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enable location permission")),
      );
      return;
    }

    lat = pos.latitude;
    lng = pos.longitude;

    setState(() {});
  }

  // ==========================================================
  // SUBMIT SHOP
  // ==========================================================
  Future submit() async {
    if (nameController.text.isEmpty ||
        addressController.text.isEmpty ||
        base64Image == null ||
        lat == null ||
        lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields & take a photo")),
      );
      return;
    }

    loading = true;
    setState(() {});

    final url =
        Uri.parse("https://abhinav-backend-4.onrender.com/api/pending/add");

    final payload = {
      "shop_name": nameController.text.trim(),
      "address": addressController.text.trim(),
      "lat": lat,
      "lng": lng,
      "image": base64Image,
      "segment": AuthService.currentUser?["segment"] ?? "all",
      "created_by": AuthService.currentUser?["_id"] ?? "",
    };

    final res = await http.post(
      url,
      headers: {
        "Authorization": "Bearer ${AuthService.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    loading = false;
    setState(() {});

    final data = jsonDecode(res.body);

    if (data["status"] == "success") {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Shop Added Successfully")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: ${data["message"]}")));
    }
  }

  // ==========================================================
  // UI
  // ==========================================================
  @override
  Widget build(BuildContext context) {
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
                    icon: const Icon(Icons.arrow_back,
                        size: 28, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Add Shop",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListView(
                    children: [
                      _input(nameController, "Shop Name"),
                      const SizedBox(height: 16),

                      _input(addressController, "Address"),
                      const SizedBox(height: 20),

                      Center(
                        child: ElevatedButton(
                          onPressed: pickPhoto,
                          child: const Text("Take Photo"),
                        ),
                      ),

                      if (base64Image != null) ...[
                        const SizedBox(height: 12),
                        Image.memory(
                          base64Decode(base64Image!),
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ],

                      const SizedBox(height: 20),

                      if (lat != null) Text("Lat: $lat\nLng: $lng"),

                      const SizedBox(height: 25),

                      loading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: submit,
                              child: const Text("Submit"),
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

  Widget _input(TextEditingController c, String label) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
