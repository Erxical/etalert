import 'dart:convert';

class Schedule {
  final String id;
  final String name;
  final String date;
  final String startTime;
  String? endTime;
  final bool isHaveEndTime;
  final String originName;
  final String destinationName;
  final double latitude;
  final double longtitude;
  final int groupId;
  final int priority;
  final bool isHaveLocation;
  final bool isFirstSchedule;

  Schedule({
    required this.id,
    required this.name,
    required this.date,
    required this.startTime,
    this.endTime,
    required this.isHaveEndTime,
    required this.originName,
    required this.destinationName,
    required this.latitude,
    required this.longtitude,
    required this.groupId,
    required this.priority,
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
      id: json['Id'],
      name: json['Name'],
      date: json['Date'],
      startTime: json['StartTime'],
      endTime: json['EndTime'],
      isHaveEndTime: json['IsHaveEndTime'],
      originName: json['OriName'],
      destinationName: json['DestName'],
      latitude: _parseDouble(json['DestLatitude']),
      longtitude: _parseDouble(json['DestLongitude']),
      groupId: json['GroupId'],
      priority: json['Priority'],
      isHaveLocation: json['IsHaveLocation'],
      isFirstSchedule: json['IsFirstSchedule'],
    );
  }
}

List<Schedule> parseSchedules(String responseBody) {
  final List<dynamic> parsed = json.decode(responseBody);
  return parsed.map<Schedule>((json) => Schedule.fromJson(json)).toList();
}
