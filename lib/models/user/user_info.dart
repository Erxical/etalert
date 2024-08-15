class UserData {
  String name;
  String email;
  String image;

  UserData({
    required this.email,
    required this.name,
    required this.image,
  });

  factory UserData.fromJson(Map json) {
    return UserData(
      name: json['Name'],
      image: json['Image'],
      email: json['Email'],
    );
  }
}
