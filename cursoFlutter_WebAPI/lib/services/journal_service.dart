import 'dart:convert';
import 'dart:io'; // Import dart:io for platform checks
import 'package:flutter_webapi_first_course/models/journal.dart';
import 'package:flutter_webapi_first_course/services/http_interceptors.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/http.dart';

class JournalService {
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

  String getUrl() {
    return "$url$resource";
  }

  Future<bool> register(Journal journal, String token) async {
    String jsonJournal = jsonEncode(journal.toMap());

    http.Response response = await client.post(Uri.parse(getUrl()),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${token}",
        },
        body: jsonJournal);

    if (response.statusCode == 201) {
      return true;
    }

    return false;
  }

  Future<List<Journal>> getAll(
      {required String id, required String token}) async {
    http.Response response = await client.get(
      Uri.parse("${url}users/$id/journals"),
      headers: {'Authorization': "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception();
    }

    List<Journal> list = [];

    List<dynamic> listDynamic = jsonDecode(response.body);

    for (var jsonMap in listDynamic) {
      list.add(Journal.fromMap(jsonMap));
    }
    return list;
  }

  Future<bool> edit(String id, Journal journal, String token) async {
    String jsonJournal = jsonEncode(journal.toMap());

    http.Response response = await client.put(Uri.parse("${getUrl()}${id}"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${token}"
        },
        body: jsonJournal);

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<bool> delete(String id, String token) async {
    http.Response response = await client.delete(Uri.parse("${getUrl()}$id"),
        headers: {'Content-Type': 'application/json', 'Authorization': "Bearer ${token}"});

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }
}
