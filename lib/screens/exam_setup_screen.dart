import 'package:flutter/material.dart';
import '../services/repository_service.dart';
import 'exam_screen.dart';

class ExamSetupScreen extends StatefulWidget {
  final RepositoryService repo;
  const ExamSetupScreen({super.key, required this.repo});

  @override
  State<ExamSetupScreen> createState() => _ExamSetupScreenState();
}

class _ExamSetupScreenState extends State<ExamSetupScreen> {
  late Map<String, bool> _blocks;

  @override
  void initState() {
    super.initState();
    final allNames = widget.repo.getAll().map((q) => q.blockName).toSet().toList();
    _blocks = { for (var name in allNames) name : true };
  }

  void _startExam() {
    // FILTRAR SOLO LOS BLOQUES MARCADOS
    final selectedNames = _blocks.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    // REGLA: Obligar a tener al menos uno marcado
    if (selectedNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("DEBES SELECCIONAR AL MENOS UN BLOQUE"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          )
      );
      return;
    }

    final questions = widget.repo.getAll()
        .where((q) => selectedNames.contains(q.blockName))
        .toList();

    Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => ExamScreen(questions: questions..shuffle()))
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color dorado = Color(0xFFD4AF37);
    return Scaffold(
      appBar: AppBar(title: const Text("PREPARACIÓN")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 25, horizontal: 40),
            child: Text("ELIGE LOS TEMARIOS QUE QUIERES INCLUIR EN TU PRUEBA",
                textAlign: TextAlign.center,
                style: TextStyle(color: dorado, letterSpacing: 2, fontSize: 10)),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: _blocks.keys.map((name) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(15)
                ),
                child: CheckboxListTile(
                  title: Text(name.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  value: _blocks[name],
                  activeColor: dorado,
                  checkColor: Colors.black,
                  onChanged: (val) => setState(() => _blocks[name] = val!),
                ),
              )).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40),
            child: ElevatedButton(
              onPressed: _startExam,
              child: const Text("INICIAR SIMULACRO"),
            ),
          ),
        ],
      ),
    );
  }
}