class Schedules {
  final List<Schedule> schedules;

  Schedules({
    required this.schedules,
  });

  factory Schedules.fromJson(Map<String, dynamic> json) {
    var list = json['schedule'] as List;
    List<Schedule> scheduleList =
        list.map((i) => Schedule.fromJson(i)).toList();

    return Schedules(
      schedules: scheduleList,
    );
  }
}

class Schedule {
  final String name;
  final String startTime;
  final String endTime;
  final bool isHaveEndTime;
  final double latitude;
  final double longtitude;
  final bool isHaveLocation;
  final bool isFirstSchedule;

  Schedule({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.isHaveEndTime,
    required this.latitude,
    required this.longtitude,
    required this.isHaveLocation,
    required this.isFirstSchedule,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      name: json['Name'],
      startTime: json['StartTime'],
      endTime: json['EndTime'],
      isHaveEndTime: json['IsHaveEndTime'],
      latitude: json['Latitude'],
      longtitude: json['Longitude'],
      isHaveLocation: json['IsHaveLocation'],
      isFirstSchedule: json['IsFirstSchedule'],
    );
  }
}
