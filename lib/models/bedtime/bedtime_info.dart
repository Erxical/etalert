class BedtimeInfo {
  String sleepTime;
  String wakeTime;

  BedtimeInfo({
    required this.sleepTime,
    required this.wakeTime,
  });

  factory BedtimeInfo.fromJson(Map<String, dynamic> json) {
    return BedtimeInfo(
      sleepTime: json['SleepTime'],
      wakeTime: json['WakeTime'],
    );
  }
}
