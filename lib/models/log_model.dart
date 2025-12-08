class LogModel {
  String userId;
  String shopId;
  String shopName;
  String salesman;

  String date;     
  String time;     
  String datetime;

  double lat;
  double lng;
  double distance;
  String result;
  String segment;
  String photoUrl;

  LogModel({
    required this.userId,
    required this.shopId,
    required this.shopName,
    required this.salesman,
    required this.date,
    required this.time,
    required this.datetime,
    required this.lat,
    required this.lng,
    required this.distance,
    required this.result,
    required this.segment,
    required this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      "salesman_id": userId,
      "shop_id": shopId,
      "lat": lat,
      "lng": lng,
      "photo_url": photoUrl,
    };
  }

  factory LogModel.fromJson(Map<String, dynamic> j) {
    return LogModel(
      userId: j["user_id"] ?? "",
      shopId: j["shop_id"] ?? "",
      shopName: j["shop_name"] ?? "",
      salesman: j["salesman"] ?? "",
      date: j["date"] ?? "",
      time: j["time"] ?? "",
      datetime: j["datetime"]?.toString() ?? "",
      lat: (j["lat"] ?? 0).toDouble(),
      lng: (j["lng"] ?? 0).toDouble(),
      distance: (j["distance"] ?? 0).toDouble(),
      result: j["result"] ?? "",
      segment: j["segment"] ?? "",
      photoUrl: j["photo_url"] ?? "",
    );
  }
}
