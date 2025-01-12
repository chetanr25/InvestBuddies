import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizService {
  String baseUrl =
      'https://state-nightowls.onrender.com/'; // Replace with your endpoint

  Future<List<Map<String, dynamic>>> fetchQuizQuestions(profile) async {
    List<Map<String, dynamic>> questions = [];

    try {
      print(profile);
      // Fetch 5 questions one by one
      for (int i = 0; i < 1; i++) {
        await Future.delayed(const Duration(seconds: 1));
        final response = await http.post(
          Uri.parse(baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(profile),
        );
        print(response.body);
        if (response.statusCode == 200) {
          final questionData = json.decode(response.body);
          questions.add(questionData);
        } else {
          print(response.body);
          throw Exception('Failed to load question ${i + 1}');
        }
      }
      print(questions);
      return questions;
    } catch (e) {
      throw Exception('Error fetching quiz questions: $e');
    }
  }
}
