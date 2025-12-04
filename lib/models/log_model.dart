class LogModel {
  final String id;
  final String userId;
  final String userName;
  final String shopId;
  final String shopName;
  final String date;
  final String time;
  final String lat;
  final String lng;
  final String distance;
  final String result;
  final String segment;

  LogModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.shopId,
    required this.shopName,
    required this.date,
    required this.time,
    required this.lat,
    required this.lng,
    required this.distance,
    required this.result,
    required this.segment,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: json["_id"].toString(),
      userId: json["userId"].toString(),
      userName: json["userName"].toString(),
      shopId: json["shopId"].toString(),
      shopName: json["shopName"].toString(),
      date: json["date"].toString(),
      time: json["time"].toString(),
      lat: json["lat"].toString(),
      lng: json["lng"].toString(),
      distance: json["distance"].toString(),
      result: json["result"].toString(),
      segment: json["segment"].toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "userName": userName,
        "shopId": shopId,
        "shopName": shopName,
        "date": date,
        "time": time,
        "lat": lat,
        "lng": lng,
        "distance": distance,
        "result": result,
        "segment": segment,
      };
}
