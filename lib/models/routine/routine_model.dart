class Routine {
  String googleId;
  String name;
  int duration;

  Routine({required this.googleId, required this.name, required this.duration});

  factory Routine.fromJson(Map json) {
    return Routine(
        googleId: json['googleId'],
        name: json['name'],
        duration: json['duration']);
  }
}
