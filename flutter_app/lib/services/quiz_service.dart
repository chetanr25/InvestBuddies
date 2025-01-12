import '../mcqs.dart';

class QuizService {
  Future<List<Map<String, dynamic>>> fetchQuizQuestions(profile) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return data.map((question) {
      return {
        'question': question['question'],
        'correct_option_letter': question['correct_option_letter'],
        'correct_answer': question['correct_answer'],
        'options': Map.fromIterables(
          ['A', 'B', 'C', 'D'],
          (question['options'] as List<String>)
              .map((opt) => opt.substring(3))
              .toList(),
        ),
      };
    }).toList();
  }
}
