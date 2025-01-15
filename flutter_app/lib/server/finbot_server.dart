import 'dart:convert';
import 'package:flutter_app/models/users_models.dart';
import 'package:http/http.dart' as h;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/users_providers.dart';

class FinbotServer {
  static Future<Map<String, dynamic>> generateQuestion(user) async {
    try {
      final userData = {
        'userId': user.userId,
        'email': user.email,
        'data': user.additionalData
      };
      print(json.encode(userData));
      print('Sending data to server');
      final response = await h.post(
        Uri.parse("https://state-nightowls.onrender.com"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(userData),
      );
      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      // else {
      //   throw Exception('Failed to generate questions: ${response.statusCode}');
      // }
    } catch (e) {
      print('Error generating questions: $e');
      throw Exception('Failed to connect to server: $e');
    }
    return {};
  }

  Future<List<Map<String, dynamic>>> generateInfo(UserModel user) async {
    List<Map<String, dynamic>> questions = [];
    for (var i = 0; i < 5; i++) {
      await Future.delayed(const Duration(milliseconds: 1000));
      questions.add(await generateQuestion(user));
    }
    print(questions);
    return questions;
  }
}

// Provider for FinbotServer
final finbotServerProvider = Provider<FinbotServer>((ref) => FinbotServer());
