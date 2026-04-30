class Option {
  final String text;
  final bool correct;
  final String rationale; // Ahora es fundamental

  Option({
    required this.text,
    required this.correct,
    this.rationale = "No hay explicación disponible.",
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'correct': correct,
    'rationale': rationale,
  };

  factory Option.fromJson(Map<String, dynamic> json) => Option(
    text: json['text'] ?? '',
    correct: json['correct'] ?? false,
    rationale: json['rationale'] ?? "Explicación no generada.",
  );
}