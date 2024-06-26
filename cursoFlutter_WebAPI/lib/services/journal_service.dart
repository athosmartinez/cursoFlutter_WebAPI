import 'dart:convert';
import 'dart:io'; // Import dart:io for platform checks
import 'package:flutter_webapi_first_course/models/journal.dart';
import 'package:flutter_webapi_first_course/services/webClient.dart';
import 'package:http/http.dart' as http;

class JournalService {
  // Use a generic URL first

  // Use a generic URL first
  String baseUrl = webClient().baseUrl;
  http.Client client = webClient().client;
  static const String resource = "journals/";

  // Determine the base URL based on the operating system
  String get url {
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
          'Authorization': "Bearer $token",
        },
        body: jsonJournal);

    if (response.statusCode != 201) {
      if (jsonDecode(response.body) == "jwt experid") {
        throw tokenNotValidException();
      }
      throw HttpException(response.body);
    }

    return true;
  }

  Future<List<Journal>> getAll(
      {required String id, required String token}) async {
    http.Response response = await client.get(
      Uri.parse("${url}users/$id/journals"),
      headers: {'Authorization': "Bearer $token"},
    );

    if (response.statusCode != 200) {
      if (jsonDecode(response.body) == "jwt experid") {
        throw tokenNotValidException();
      }
      throw HttpException(response.body);
    }

    List<Journal> list = [];

    List<dynamic> listDynamic = jsonDecode(response.body);

    for (var jsonMap in listDynamic) {
      list.add(Journal.fromMap(jsonMap));
    }
    return list;
  }

  Future<bool> edit(String id, Journal journal, String token) async {
    journal.updatedAt = DateTime.now();

    String jsonJournal = jsonEncode(journal.toMap());

    http.Response response = await client.put(Uri.parse("${getUrl()}$id"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer $token"
        },
        body: jsonJournal);

    if (response.statusCode != 200) {
      if (jsonDecode(response.body) == "jwt experid") {
        throw tokenNotValidException();
      }
      throw HttpException(response.body);
    }

    return true;
  }

  Future<bool> delete(String id, String token) async {
    http.Response response = await client.delete(Uri.parse("${getUrl()}$id"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer $token"
        });

    if (response.statusCode != 200) {
      if (jsonDecode(response.body) == "jwt experid") {
        throw tokenNotValidException();
      }
      throw HttpException(response.body);
    }

    return true;
  }
}

class tokenNotValidException implements Exception {}
