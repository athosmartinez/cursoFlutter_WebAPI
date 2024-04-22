import 'dart:convert';
import 'dart:io';  // Import dart:io for platform checks
import 'package:http/http.dart' as http;

class JournalService {
  // Use a generic URL first
  static const String baseUrl = "http://localhost:3000/";
  static const String resource = "learnhttp/";

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

  String getUrl() {
    return "$url$resource";
  }

  Future<void> register(String content) async {
    await http.post(
      Uri.parse(getUrl()),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'content': content}),
    );
  }

  Future<String> get() async {
    http.Response response = await http.get(Uri.parse(getUrl()));
    print(response.body);
    return response.body;
  }
}
