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
  double distance;   // ⭐ used for shop distance match
  String result;     // ⭐ Inside / Outside
  String segment;

  String photoUrl;   // ⭐ backend key: image_url or photo_url

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

  // ⭐ When sending log to backend (rare case)
  Map<String, dynamic> toJson() {
  return {
    "user_id": userId,
    "salesman_name": salesman,
    "shop_id": shopId,
    "shop_name": shopName,
    "lat": lat,
    "lng": lng,
    "date": date,
    "time": time,
    "distance": distance,
    "result": result.toLowerCase(),
    "segment": segment.toLowerCase(),
    "image_url": photoUrl,
  };
}
  // ⭐ When receiving logs from backend
  factory LogModel.fromJson(Map<String, dynamic> j) {
    return LogModel(
      userId: j["user_id"] ?? "",
      shopId: j["shop_id"] ?? "",
      shopName: j["shop_name"] ?? "",
      salesman: j["salesman_name"] ?? j["salesman"] ?? "",
      date: j["date"] ?? "",
      time: j["time"] ?? "",
      datetime: j["datetime"]?.toString() ?? "",
      lat: (j["lat"] ?? 0).toDouble(),
      lng: (j["lng"] ?? 0).toDouble(),
      distance: (j["distance"] ?? 0).toDouble(),
      result: j["result"] ?? "",
      segment: j["segment"] ?? "",
      photoUrl: j["image_url"] ?? j["photo_url"] ?? "",
    );
  }
}
