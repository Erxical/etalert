class UserEdited {
  String name;
  String image;

  UserEdited({
    required this.name,
    required this.image,
  });

  factory UserEdited.fromJson(Map json) {
    return UserEdited(
      name: json['Name'],
      image: json['Image'],
    );
  }
}
