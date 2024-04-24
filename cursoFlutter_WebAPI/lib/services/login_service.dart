import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Import dart:io for platform checks
import 'package:flutter_webapi_first_course/models/journal.dart';
import 'package:flutter_webapi_first_course/services/http_interceptors.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class loginService {
  // Use a generic URL first
  static const String baseUrl = "http://localhost:3000/";
  static const String resource = "journals/";

  http.Client client =
      InterceptedClient.build(interceptors: [LoggingInterceptor()]);

  // Determine the base URL based on the operating system
  static String get url {
    if (Platform.isAndroid) {
      // Use the special IP for Android emulator
      return "http://10.0.2.2:3000/";
    } else if (Platform.isIOS) {
      // Use localhost for iOS as it works in iOS Simulator
      return "http://localhost:3000/";
    } else {
      // Default to localhost which might be applicable in other environments
      return baseUrl;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    http.Response response = await client.post(Uri.parse("${url}login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "password": password}));

    if (response.statusCode != 200) {
      String content = jsonDecode(response.body);
      switch (content) {
        case "Cannot find user":
          throw UserNotFindException();
      }
      throw HttpException(response.body);
    }

    saveUserInfos(response.body);
    return true;
  }

  Future<bool> register(
      {required String email, required String password}) async {
    http.Response response = await client.post(Uri.parse("${url}register"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "password": password}));

    if (response.statusCode != 201) {
      throw HttpException(response.body);
    }

    saveUserInfos(response.body);
    return true;
  }

  saveUserInfos(String body) async {
    Map<String, dynamic> map = jsonDecode(body);
    String token = map["accessToken"];
    String email = map["user"]["email"];
    int userId = map["user"]["id"];
    SharedPreferences presfs = await SharedPreferences.getInstance();

    presfs.setString("accessToken", token);
    presfs.setString("email", email);
    presfs.setInt("userId", userId);
  }
}

class UserNotFindException implements Exception {}
