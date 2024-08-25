class Login {
  final String accessToken;
  final String refreshToken;
  final String accessTokenExpired;
  final String refreshTokenExpired;

  Login({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpired,
    required this.refreshTokenExpired,
  });

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
        accessToken: json['AccessToken'],
        refreshToken: json['RefreshToken'],
        accessTokenExpired: json['AccessTokenExpired'],
        refreshTokenExpired: json['RefreshTokenExpired']);
  }
}
