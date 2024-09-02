class ScheduleReq {
  final String googleId;
  final String name;
  final String date;
  final String startTime;
  final String? endTime;
  final bool isHaveEndTime;
  final double? oriLatitude;
  final double? oriLongtitude;
  final double? destLatitude;
  final double? destLongtitude;
  final bool isHaveLocation;
  final bool isFirstSchedule;
  final String? departTime;

  ScheduleReq({
    required this.googleId,
    required this.name,
    required this.date,
    required this.startTime,
    this.endTime,
    required this.isHaveEndTime,
    this.oriLatitude,
    this.oriLongtitude,
    this.destLatitude,
    this.destLongtitude,
    required this.isHaveLocation,
    required this.isFirstSchedule,
    this.departTime,
  });
}
