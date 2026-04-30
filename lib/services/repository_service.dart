import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/question.dart';

class RepositoryService {
  List<Question> _questions = [];

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/questions_data_2025.json';
  }

  Future<void> load() async {
    try {
      final file = File(await _getFilePath());
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _questions = jsonList.map((json) => Question.fromJson(json)).toList();
      }
    } catch (e) {
      _questions = [];
    }
  }

  Future<void> save() async {
    try {
      final file = File(await _getFilePath());
      final String jsonContent = jsonEncode(_questions.map((q) => q.toJson()).toList());
      await file.writeAsString(jsonContent);
    } catch (e) {
      print("Error al guardar: $e");
    }
  }

  List<Question> getAll() => _questions;

  void addQuestion(Question q) => _questions.add(q);

  void updateQuestion(int index, Question updated) {
    if (index >= 0 && index < _questions.length) {
      _questions[index] = updated;
    }
  }

  void deleteQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _questions.removeAt(index);
    }
  }
}