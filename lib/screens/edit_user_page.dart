import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class EditUserPage extends StatefulWidget {
  final UserModel user;
  const EditUserPage({super.key, required this.user});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  final userService = UserService();

  late TextEditingController nameCtrl;
  late TextEditingController mobileCtrl;
  late TextEditingController passCtrl;

  String? selectedRole;
  String? selectedSegment;

  bool showPass = false;

  @override
  void initState() {
    super.initState();

    nameCtrl = TextEditingController(text: widget.user.name);
    mobileCtrl = TextEditingController(text: widget.user.mobile);
    passCtrl = TextEditingController(text: widget.user.password);

    selectedRole = widget.user.role.trim().toLowerCase();
    selectedSegment = widget.user.segment.trim().toLowerCase();
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = UserModel(
  id: widget.user.id,                      // ⭐ VERY IMPORTANT
  userId: widget.user.userId,
  name: nameCtrl.text.trim(),
  mobile: mobileCtrl.text.trim(),
  password: passCtrl.text.trim(),
  role: selectedRole!,
  segment: selectedSegment!,
  createdAt: widget.user.createdAt,
);


    bool ok = await userService.updateUser(updated);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User Updated Successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Update Failed")),
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
              // 🔙 BACK BUTTON + HEADER
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        size: 28, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Edit User",
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),

                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        textField(nameCtrl, "Name"),
                        const SizedBox(height: 15),

                        textField(mobileCtrl, "Mobile",
                            keyboardType: TextInputType.phone),
                        const SizedBox(height: 15),

                        // 🔐 PASSWORD + TOGGLE
                        TextFormField(
                          controller: passCtrl,
                          obscureText: !showPass,
                          decoration: InputDecoration(
                            labelText: "Password",
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: IconButton(
                              icon: Icon(
                                showPass
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.blue,
                              ),
                              onPressed: () =>
                                  setState(() => showPass = !showPass),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? "Enter Password" : null,
                        ),

                        const SizedBox(height: 15),

                        // ROLE
                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          decoration: dropdownDecor("Role"),
                          items: const [
                            DropdownMenuItem(
                                value: "master", child: Text("Master")),
                            DropdownMenuItem(
                                value: "manager", child: Text("Manager")),
                            DropdownMenuItem(
                                value: "salesman", child: Text("Salesman")),
                          ],
                          onChanged: (v) =>
                              setState(() => selectedRole = v),
                        ),

                        const SizedBox(height: 15),

                        // SEGMENT
                        DropdownButtonFormField<String>(
                          value: selectedSegment,
                          decoration: dropdownDecor("Segment"),
                          items: const [
                            DropdownMenuItem(
                                value: "fmcg", child: Text("FMCG")),
                            DropdownMenuItem(
                                value: "pipes", child: Text("PIPES")),
                          ],
                          onChanged: (v) =>
                              setState(() => selectedSegment = v),
                        ),

                        const SizedBox(height: 22),

                        // SAVE BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: save,
                            child: const Text(
                              "Save Changes",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ⭐ Modern TextField
  Widget textField(TextEditingController ctrl, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      validator: (v) => v!.isEmpty ? "Enter $label" : null,
    );
  }

  // ⭐ Modern Dropdown Decoration
  InputDecoration dropdownDecor(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
