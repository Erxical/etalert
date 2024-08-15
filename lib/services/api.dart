import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Api {
  static BaseOptions baseURL = BaseOptions(baseUrl: dotenv.get('BASE_URL'));
  static Dio dio = Dio(baseURL);

  static setToken(String token) {
    dio.options.headers["Authorization"] = "Bearer $token";
  }
}
