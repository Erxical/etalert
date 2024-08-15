class Schedules {
  final DateTime dateTime;
  final List<Schedule> schedules;

  Schedules({
    required this.dateTime,
    required this.schedules,
  });

  factory Schedules.fromJson(Map<String, dynamic> json) {
    var list = json['schedule'] as List;
    List<Schedule> scheduleList =
        list.map((i) => Schedule.fromJson(i)).toList();

    return Schedules(
      dateTime: json['dateTime'],
      schedules: scheduleList,
    );
  }
}

class Schedule {
  final String name;
  final String location;

  Schedule({
    required this.name,
    required this.location,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      name: json['name'],
      location: json['location'],
    );
  }
}
