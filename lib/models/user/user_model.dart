class User {
  String name;
  String email;
  String googleId;
  String image;

  User({
    required this.googleId,
    required this.email,
    required this.name,
    required this.image,
  });

  factory User.fromJson(Map json) {
    return User(
      googleId: json['googleId'],
      email: json['email'],
      name: json['name'],
      image: json['image'],
    );
  }
}
