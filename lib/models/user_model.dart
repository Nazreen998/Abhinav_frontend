class UserModel {
  final String? id;
  final String userId;
  final String name;
  final String mobile;
  final String role;
  final String segment;
  final String password;

  UserModel({
    this.id,
    required this.userId,
    required this.name,
    required this.mobile,
    required this.role,
    required this.segment,
    required this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["_id"]?.toString(),
      userId: json["user_id"]?.toString() ?? "",
      name: json["name"] ?? "",
      mobile: json["mobile"] ?? "",
      role: json["role"] ?? "",
      segment: json["segment"] ?? "",
      password: json["password"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "mobile": mobile,
      "role": role,
      "password": password,
      "segment": segment,
    };
  }
}
