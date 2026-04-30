import 'option.dart';

class Question {
  final String statement;
  final List<Option> options;
  final List<String> topics;
  final String author;
  final String blockName; // NUEVO: Identificador del grupo

  Question({
    required this.statement,
    required this.options,
    required this.topics,
    this.author = 'Anónimo',
    this.blockName = 'General', // Por defecto van a General
  });

  Map<String, dynamic> toJson() => {
    'statement': statement,
    'options': options.map((e) => e.toJson()).toList(),
    'topics': topics,
    'author': author,
    'blockName': blockName,
  };

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    statement: json['statement'],
    options: (json['options'] as List).map((e) => Option.fromJson(e)).toList(),
    topics: List<String>.from(json['topics']),
    author: json['author'],
    blockName: json['blockName'] ?? 'General',
  );
}