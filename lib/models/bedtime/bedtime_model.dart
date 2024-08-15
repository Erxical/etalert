class Bedtime {
  String googleId;
  String sleepTime;
  String wakeTime;

  Bedtime(
      {required this.googleId,
      required this.sleepTime,
      required this.wakeTime});

  factory Bedtime.fromJson(Map json) {
    return Bedtime(
      googleId: json['googleId'],
      sleepTime: json['Name'],
      wakeTime: json['Image'],
    );
  }
}
