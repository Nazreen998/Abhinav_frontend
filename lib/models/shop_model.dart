class ShopModel {
  final String id;
  final String shopId;
  final String shopName;
  final String address;
  final double lat;
  final double lng;
  final String segment;

  ShopModel({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.address,
    required this.lat,
    required this.lng,
    required this.segment,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json["_id"] ?? "",
      shopId: json["shop_id"] ?? "",
      shopName: json["shop_name"] ?? "",
      address: json["address"] ?? "",
      lat: double.tryParse(json["lat"].toString()) ?? 0,
      lng: double.tryParse(json["lng"].toString()) ?? 0,
      segment: json["segment"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "shop_id": shopId,
        "shop_name": shopName,
        "address": address,
        "lat": lat,
        "lng": lng,
        "segment": segment,
      };
}
