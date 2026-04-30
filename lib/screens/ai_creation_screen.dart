import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/gemini_service.dart';
import '../models/question.dart';
import '../models/option.dart';

class AICreationScreen extends StatefulWidget {
  const AICreationScreen({super.key});

  @override
  State<AICreationScreen> createState() => _AICreationScreenState();
}

class _AICreationScreenState extends State<AICreationScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _blockController = TextEditingController();
  final TextEditingController _countController = TextEditingController(text: "5");
  final GeminiService _gemini = GeminiService();

  bool _isLoading = false;
  List<Question> _preview = [];
  String? _pdfBase64;
  String? _fileName;
  String _difficulty = "Media";

  Future<void> _pickPDF() async {
    try {
      debugPrint("Abriendo selector de archivos...");
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (result != null) {
        setState(() {
          _fileName = result.files.single.name;
          _pdfBase64 = base64Encode(result.files.single.bytes!);
          debugPrint("PDF cargado: $_fileName");
          if (_blockController.text.isEmpty) {
            _blockController.text = _fileName!.replaceAll(".pdf", "").toUpperCase();
          }
        });
      }
    } catch (e) {
      debugPrint("Error al cargar PDF: $e");
      _showError("No se pudo cargar el archivo");
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 5),
        )
    );
  }

  void _generate() async {
    final String blockName = _blockController.text.trim();
    final String sourceContent = _textController.text.trim();
    final int? count = int.tryParse(_countController.text);

    // Validaciones iniciales
    if (blockName.isEmpty) {
      _showError("Asigna un nombre al bloque (ej: Anatomía)");
      return;
    }
    if (count == null || count <= 0) {
      _showError("Introduce un número válido de preguntas");
      return;
    }
    if (_pdfBase64 == null && sourceContent.isEmpty) {
      _showError("Pega texto o sube un PDF para generar preguntas");
      return;
    }

    setState(() => _isLoading = true);
    debugPrint("Iniciando generación de $count preguntas...");

    try {
      final data = await _gemini.generateQuestions(
        sourceText: sourceContent.isEmpty ? null : sourceContent,
        pdfBase64: _pdfBase64,
        count: count,
        difficulty: _difficulty,
      );

      debugPrint("Preguntas recibidas: ${data.length}");

      if (data.isEmpty) {
        _showError("La generación falló. Intenta con otro texto.");
      } else {
        setState(() {
          _preview = data.map((q) => Question(
            statement: q['statement'] ?? "Sin enunciado",
            blockName: blockName,
            topics: List<String>.from(q['topics'] ?? []),
            options: (q['options'] as List).map((o) => Option(
                text: o['text'] ?? "Opción vacía",
                correct: o['correct'] ?? false,
                rationale: o['rationale'] ?? ""
            )).toList(),
          )).toList();
        });
      }
    } catch (e) {
      debugPrint("Error crítico en _generate: $e");
      String errorMsg = e.toString().replaceAll("Exception: ", "");
      if (errorMsg.contains("API_KEY_MISSING")) {
        errorMsg = "No se detectó la API Key. Lanza la app con --dart-define.";
      }
      _showError("Error al generar: $errorMsg");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color dorado = Color(0xFFD4AF37);

    return Scaffold(
      appBar: AppBar(title: const Text("IMPORTAR BLOQUE")),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: dorado),
            const SizedBox(height: 20),
            const Text("Generando Preguntas...", style: TextStyle(color: dorado, letterSpacing: 2, fontSize: 10)),
            const SizedBox(height: 10),
            const Text("Esto puede tardar un poco", style: TextStyle(color: Colors.white24, fontSize: 10)),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_preview.isEmpty) ...[
              const Text("TEMA / BLOQUE", style: TextStyle(color: dorado, fontSize: 10, letterSpacing: 2)),
              const SizedBox(height: 10),
              TextField(
                  controller: _blockController,
                  decoration: const InputDecoration(hintText: "Nombre del conjunto (ej: TEMA 1)")
              ),
              const SizedBox(height: 25),
              const Text("CONTENIDO BASE", style: TextStyle(color: dorado, fontSize: 10, letterSpacing: 2)),
              const SizedBox(height: 10),
              TextField(
                controller: _textController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Pega tus apuntes aquí o adjunta un archivo PDF...",
                  suffixIcon: IconButton(
                      onPressed: _pickPDF,
                      icon: Icon(Icons.picture_as_pdf, color: _pdfBase64 != null ? Colors.greenAccent : dorado)
                  ),
                ),
              ),
              if (_fileName != null)
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text("📎 Archivo: $_fileName", style: const TextStyle(color: Colors.white54, fontSize: 11))
                ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                          controller: _countController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "CANTIDAD")
                      )
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _difficulty,
                      items: ["Baja", "Media", "Alta"]
                          .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                          .toList(),
                      onChanged: (v) => setState(() => _difficulty = v!),
                      decoration: const InputDecoration(labelText: "DIFICULTAD"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                  onPressed: _generate,
                  child: const Text("GENERAR PREGUNTAS")
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("BLOQUE: ${_blockController.text}", style: const TextStyle(color: dorado, letterSpacing: 2)),
                  Text("${_preview.length} Preguntas", style: const TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 20),
              ..._preview.map((q) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(q.statement, style: const TextStyle(fontSize: 12)),
                    subtitle: Text("${q.options.length} opciones", style: const TextStyle(fontSize: 10, color: dorado)),
                  )
              )),
              const SizedBox(height: 30),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context, _preview),
                  child: const Text("GUARDAR EN EL ARCHIVO")
              ),
              TextButton(
                  onPressed: () => setState(() => _preview = []),
                  child: const Text("DESCARTAR Y VOLVER", style: TextStyle(color: Colors.white38))
              ),
            ]
          ],
        ),
      ),
    );
  }
}