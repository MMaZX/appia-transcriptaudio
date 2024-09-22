import 'package:shared_preferences/shared_preferences.dart';

class API {
  Future<String> getPath(String path) async {
    String baseUrl = await SharedToken().getBaseUrl();
    return "$baseUrl/api/$path";
  }
}

class ContentAPI {
  static String recordSpeak = "transcribe/audio";
  static String downloadWordAnalysis = "transcribe/generate-word";
  static String analizarMensaje = "analysis";
  static String resumirMensaje = "summary";
}

class SharedToken {
  static String baseUrlToken = "baseUrlTOkenPreferences";

  Future<void> setBaseUrl(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(baseUrlToken, url);
  }

  Future<String> getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String path = prefs.getString(baseUrlToken) ?? "http://localhost:4000";
    return path;
  }
}
