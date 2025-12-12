class PendingShopModel {
  final String mongoId;
  final String shopName;
  final String address;
  final double lat;
  final double lng;
  final String segment;
  final String? createdBy;      // nullable
  final String createdAt;       // ISO string
  final String? imageBase64;

  PendingShopModel({
    required this.mongoId,
    required this.shopName,
    required this.address,
    required this.lat,
    required this.lng,
    required this.segment,
    required this.createdAt,
    this.createdBy,
    this.imageBase64,
  });

  factory PendingShopModel.fromJson(Map<String, dynamic> json) {
    return PendingShopModel(
      mongoId: json["_id"]?.toString() ?? "",
      shopName: json["shopName"]?.toString() ?? "",
      address: json["address"]?.toString() ?? "",
      lat: (json["latitude"] ?? 0).toDouble(),
      lng: (json["longitude"] ?? 0).toDouble(),
      segment: json["segment"]?.toString() ?? "",
      createdAt: json["createdAt"]?.toString() ?? "",
      createdBy: json["createdBy"]?.toString(), // may be null
      imageBase64: json["image"]?.toString(),
    );
  }
}
