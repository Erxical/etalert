class Routine {
  String googleId;
  String name;
  int duration;
  int order;

  Routine(
      {required this.googleId,
      required this.name,
      required this.duration,
      required this.order});

  factory Routine.fromJson(Map json) {
    return Routine(
        googleId: json['googleId'],
        name: json['name'],
        duration: json['duration'],
        order: json['order']);
  }
}
