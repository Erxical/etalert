import 'dart:convert';

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

  static double _parseDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.parse(value);
    }
    throw FormatException('Invalid number format for: $value');
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      name: json['Name'],
      startTime: json['StartTime'],
      endTime: json['EndTime'],
      isHaveEndTime: json['IsHaveEndTime'],
      latitude: _parseDouble(json['Latitude']),
      longtitude: _parseDouble(json['Longitude']),
      isHaveLocation: json['IsHaveLocation'],
      isFirstSchedule: json['IsFirstSchedule'],
    );
  }
}

List<Schedule> parseSchedules(String responseBody) {
  final List<dynamic> parsed = json.decode(responseBody);
  return parsed.map<Schedule>((json) => Schedule.fromJson(json)).toList();
}
