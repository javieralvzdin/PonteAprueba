import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/option.dart';
import 'result_screen.dart';

class ExamScreen extends StatefulWidget {
  final List<Question> questions;
  const ExamScreen({super.key, required this.questions});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedIndex;
  bool _isSubmitted = false;

  void _submitAnswer(int index) {
    if (_isSubmitted) return;
    setState(() {
      _selectedIndex = index;
      _isSubmitted = true;
      if (widget.questions[_currentIndex].options[index].correct) _score++;
    });
  }

  void _showExplanation() {
    final option = widget.questions[_currentIndex].options[_selectedIndex!];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F26),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("JUSTIFICACIÓN", style: TextStyle(color: Color(0xFFD4AF37), letterSpacing: 2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text(
              option.rationale,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("ENTENDIDO")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color dorado = Color(0xFFD4AF37);
    final question = widget.questions[_currentIndex];
    final progress = (_currentIndex + 1) / widget.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text("PREGUNTA ${_currentIndex + 1} / ${widget.questions.length}", style: const TextStyle(fontSize: 12, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: progress, backgroundColor: Colors.white10, color: dorado, minHeight: 6),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Text(question.statement, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4)),
                  const SizedBox(height: 40),
                  ...List.generate(question.options.length, (index) {
                    final opt = question.options[index];
                    Color color = _isSubmitted ? (opt.correct ? Colors.greenAccent : (_selectedIndex == index ? Colors.redAccent : Colors.white10)) : Colors.white10;
                    return GestureDetector(
                      onTap: () => _submitAnswer(index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color, width: 1.5),
                          color: color.withOpacity(0.05),
                        ),
                        child: Row(
                          children: [
                            Text(String.fromCharCode(65 + index), style: TextStyle(color: color == Colors.white10 ? dorado : color, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 15),
                            Expanded(child: Text(opt.text)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          if (_isSubmitted) Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                OutlinedButton(
                  onPressed: _showExplanation,
                  child: const Text("VER JUSTIFICACIÓN"),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    if (_currentIndex < widget.questions.length - 1) {
                      setState(() { _currentIndex++; _selectedIndex = null; _isSubmitted = false; });
                    } else {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => ResultScreen(score: _score, total: widget.questions.length)));
                    }
                  },
                  child: Text(_currentIndex < widget.questions.length - 1 ? "CONTINUAR" : "FINALIZAR"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}