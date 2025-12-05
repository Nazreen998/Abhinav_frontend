import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AddShopPage extends StatefulWidget {
  const AddShopPage({super.key});

  @override
  State<AddShopPage> createState() => _AddShopPageState();
}

class _AddShopPageState extends State<AddShopPage> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();

  File? imageFile;
  String? base64Image;

  double? lat;
  double? lng;

  bool loading = false;

  // 📸 PICK PHOTO
  Future pickPhoto() async {
    // -------------------------
    // WEB MODE
    // -------------------------
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        base64Image = base64Encode(result.files.single.bytes!);
        setState(() {});
        getLocation();
      }
      return;
    }

    // -------------------------
    // WINDOWS MODE
    // -------------------------
    if (Platform.isWindows) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        imageFile = File(result.files.single.path!);

        final bytes = await imageFile!.readAsBytes();
        base64Image = base64Encode(bytes);

        setState(() {});
        getLocation();
      }
      return;
    }

    // -------------------------
    // ANDROID / IOS MODE
    // -------------------------
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);

    if (picked != null) {
      imageFile = File(picked.path);

      final bytes = await imageFile!.readAsBytes();
      base64Image = base64Encode(bytes);

      setState(() {});
      getLocation();
    }
  }

  // 📍 LOCATION
  Future getLocation() async {
    LocationPermission perm = await Geolocator.requestPermission();

    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location Permission Required")),
      );
      return;
    }

    Position pos = await Geolocator.getCurrentPosition();

    lat = pos.latitude;
    lng = pos.longitude;

    setState(() {});
  }

  // 📤 SUBMIT SHOP
  Future submit() async {
    if (nameController.text.isEmpty ||
        addressController.text.isEmpty ||
        lat == null ||
        lng == null ||
        base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields & pick image")),
      );
      return;
    }

    loading = true;
    setState(() {});

    final url = Uri.parse(
        "https://backend-abhinav-tracking.onrender.com/api/pending/add");

    final payload = {
      "shop_name": nameController.text.trim(),
      "address": addressController.text.trim(),
      "lat": lat,
      "lng": lng,
      "image": base64Image, // 🔥 FIXED FOR ALL PLATFORMS
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Shop Added Successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${data["message"]}")),
      );
    }
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
                  )
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066CC),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 26),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Take Photo",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                      if (imageFile != null && !kIsWeb) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(imageFile!, height: 160),
                        ),
                      ],

                      if (kIsWeb && base64Image != null) ...[
                        const SizedBox(height: 12),
                        Image.memory(
                          base64Decode(base64Image!),
                          height: 160,
                        ),
                      ],

                      const SizedBox(height: 20),

                      if (lat != null)
                        Text(
                          "Location:\nLat: $lat\nLng: $lng",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),

                      const SizedBox(height: 25),

                      loading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: submit,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15),
                                  backgroundColor: const Color(0xFF0066CC),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  "Submit",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
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
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String label) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
