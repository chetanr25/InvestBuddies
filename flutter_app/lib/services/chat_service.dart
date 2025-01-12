import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatService {
  static const String endpoint = 'https://state-nightowls.onrender.com/fin_bot';

  Future<String> getChatResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'prompt': prompt}),
      );
      print(response.body);
      // if (response.statusCode == 200) {
      // final responseData = json.decode(response.body);
      // print(responseData);
      return response.body ?? 'No response from bot';
      // } else {
      //   print(response.body);
      //   throw Exception('Failed to get response: ${response.statusCode}');
      // }
    } catch (e) {
      print(e);
      throw Exception('Error getting chat response: $e');
    }
  }
}
