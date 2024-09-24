class ScheduleReq {
  final String googleId;
  final String name;
  final String date;
  final String startTime;
  final String? endTime;
  final bool isHaveEndTime;
  final String? oriName;
  final double? oriLatitude;
  final double? oriLongtitude;
  final String? desName;
  final double? destLatitude;
  final double? destLongtitude;
  final bool isHaveLocation;
  final bool isFirstSchedule;
  final bool isTraveling;

  ScheduleReq({
    required this.googleId,
    required this.name,
    required this.date,
    required this.startTime,
    this.endTime,
    required this.isHaveEndTime,
    this.oriName,
    this.oriLatitude,
    this.oriLongtitude,
    this.desName,
    this.destLatitude,
    this.destLongtitude,
    required this.isHaveLocation,
    required this.isFirstSchedule,
    required this.isTraveling,
  });
}
