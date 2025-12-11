class ShopModel {
  final String shopId;
  final String shopName;
  final String address;
  final double lat;
  final double lng;
  final String segment;
  final String createdBy;
  final String createdAt;
  final String status;

  ShopModel({
    required this.shopId,
    required this.shopName,
    required this.address,
    required this.lat,
    required this.lng,
    required this.segment,
    required this.createdBy,
    required this.createdAt,
    required this.status,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();

    String s = v.toString().trim();
    if (s.isEmpty || s.toLowerCase() == "null") return 0.0;

    return double.tryParse(s) ?? 0.0;
  }

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      shopId: json["shop_id"] ?? "",
      shopName: json["shop_name"] ?? "",
      address: json["address"] ?? "",
      lat: _toDouble(json["lat"]),
      lng: _toDouble(json["lng"]),
      segment: json["segment"] ?? "",
      createdBy: json["created_by"] ?? "",
      createdAt: json["created_at"] ?? "",
      status: json["status"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "shop_id": shopId,
        "shop_name": shopName,
        "address": address,
        "lat": lat,
        "lng": lng,
        "segment": segment,
        "created_by": createdBy,
        "created_at": createdAt,
        "status": status,
      };
}
