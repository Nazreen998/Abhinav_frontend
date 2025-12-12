class UserModel {
  final String? id;
  final String userId;
  final String name;
  final String mobile;
  final String role;
  final String segment;
  final String? password;

  // ⬇️ ADD THIS
  final String? createdAt;

  UserModel({
    this.id,
    required this.userId,
    required this.name,
    required this.mobile,
    required this.role,
    required this.segment,
    this.password,
    this.createdAt, // ⬅️
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["_id"],
      userId: json["user_id"] ?? "",
      name: json["name"] ?? "",
      mobile: json["mobile"]?.toString() ?? "",
      role: json["role"]?.toString().toLowerCase() ?? "",
      segment: json["segment"] ?? "",
      password: json["password"], // ✅ ADD THIS
      createdAt: json["createdAt"] ?? json["updatedAt"], // ⬅️
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "name": name,
      "mobile": mobile,
      "role": role,
      "segment": segment,
      if (password != null) "password": password,
    };
  }
}
