import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/option.dart';

class ManualQuestionScreen extends StatefulWidget {
  final Question? questionToEdit;
  const ManualQuestionScreen({super.key, this.questionToEdit});

  @override
  State<ManualQuestionScreen> createState() => _ManualQuestionScreenState();
}

class _ManualQuestionScreenState extends State<ManualQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _statementController = TextEditingController();
  final _topicController = TextEditingController();
  // NUEVO: Controlador para el nombre del bloque
  final _blockController = TextEditingController(text: "Manuales");

  final List<TextEditingController> _optTexts = [];
  final List<TextEditingController> _optRats = [];
  int _correctIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.questionToEdit != null) {
      _statementController.text = widget.questionToEdit!.statement;
      _topicController.text = widget.questionToEdit!.topics.join(", ");
      _blockController.text = widget.questionToEdit!.blockName; // Cargar bloque si editamos
      for (var opt in widget.questionToEdit!.options) {
        _optTexts.add(TextEditingController(text: opt.text));
        _optRats.add(TextEditingController(text: opt.rationale));
      }
      _correctIndex = widget.questionToEdit!.options.indexWhere((o) => o.correct);
      if (_correctIndex == -1) _correctIndex = 0;
    } else {
      _addOptionField(); _addOptionField();
    }
  }

  void _addOptionField() {
    if (_optTexts.length < 4) {
      setState(() {
        _optTexts.add(TextEditingController());
        _optRats.add(TextEditingController());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color dorado = Color(0xFFD4AF37);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.questionToEdit == null ? 'NUEVA ENTRADA' : 'EDITAR REGISTRO',
            style: const TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          children: [
            // NUEVO CAMPO: Bloque
            TextFormField(
              controller: _blockController,
              decoration: const InputDecoration(
                labelText: 'NOMBRE DEL BLOQUE / TEMA',
                hintText: 'Ej: Miscelánea, Tema 1...',
              ),
              validator: (v) => v!.isEmpty ? 'El nombre del bloque es obligatorio' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _statementController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'ENUNCIADO DE LA PREGUNTA',
                alignLabelWithHint: true,
              ),
              validator: (v) => v!.isEmpty ? 'Escribe el enunciado' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _topicController,
              decoration: const InputDecoration(labelText: 'ETIQUETAS (opcional)'),
            ),
            const SizedBox(height: 40),
            const Text('OPCIONES DE RESPUESTA',
                style: TextStyle(color: dorado, letterSpacing: 3, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            for (int i = 0; i < _optTexts.length; i++) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: i == _correctIndex ? dorado : Colors.white10, width: 1.5),
                ),
                child: Row(
                  children: [
                    Radio<int>(
                      value: i,
                      groupValue: _correctIndex,
                      activeColor: dorado,
                      onChanged: (v) => setState(() => _correctIndex = v!),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _optTexts[i],
                        decoration: const InputDecoration(
                          hintText: 'Respuesta...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                        ),
                        validator: (v) => v!.isEmpty ? 'Falta texto' : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_optTexts.length < 4)
              TextButton.icon(
                onPressed: _addOptionField,
                icon: const Icon(Icons.add_circle_outline, color: dorado),
                label: const Text('AÑADIR OPCIÓN', style: TextStyle(color: dorado, letterSpacing: 2)),
              ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final List<Option> options = List.generate(_optTexts.length, (i) => Option(
                    text: _optTexts[i].text,
                    rationale: _optRats[i].text,
                    correct: i == _correctIndex,
                  ));

                  // AQUÍ ESTABA EL ERROR: Faltaban blockName y los parámetros obligatorios
                  final q = Question(
                    statement: _statementController.text,
                    author: 'Manual',
                    options: options,
                    blockName: _blockController.text, // <--- ASIGNAR EL BLOQUE
                    topics: _topicController.text.isEmpty ? [] : [_topicController.text],
                  );

                  Navigator.pop(context, q);
                }
              },
              child: const Text('CONFIRMAR Y GUARDAR'),
            ),
          ],
        ),
      ),
    );
  }
}