import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/repository_service.dart';

class ManageQuestionsScreen extends StatefulWidget {
  final RepositoryService repo;
  const ManageQuestionsScreen({super.key, required this.repo});

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  // Función para agrupar preguntas por bloque
  Map<String, List<int>> _getGroupedIndices() {
    final questions = widget.repo.getAll();
    final Map<String, List<int>> groups = {};

    for (int i = 0; i < questions.length; i++) {
      // Si el campo blockName no existe en tu clase Question, esto saldrá en rojo.
      // Asegúrate de actualizar lib/models/question.dart con el código correspondiente.
      final block = questions[i].blockName;
      if (!groups.containsKey(block)) {
        groups[block] = [];
      }
      groups[block]!.add(i);
    }
    return groups;
  }

  void _confirmDelete(int index) {
    const Color dorado = Color(0xFFD4AF37);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F26),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          // Se cambió 'border' por 'side' y se usa 'BorderSide' para corregir el error
          side: BorderSide(color: dorado.withOpacity(0.3), width: 1),
        ),
        title: const Text("¿ELIMINAR PREGUNTA?",
            style: TextStyle(color: dorado, letterSpacing: 2, fontSize: 16)),
        content: const Text("Esta pregunta se borrará permanentemente del archivo local."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.repo.deleteQuestion(index);
                widget.repo.save();
              });
              Navigator.pop(ctx);
            },
            child: const Text("BORRAR", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color dorado = Color(0xFFD4AF37);
    final groupedData = _getGroupedIndices();
    final questions = widget.repo.getAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text("GESTIÓN DE PREGUNTAS"),
        centerTitle: true,
      ),
      body: questions.isEmpty
          ? const Center(
          child: Text("NO HAY PREGUNTAS GUARDADAS",
              style: TextStyle(color: Colors.white24, letterSpacing: 2)))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: groupedData.keys.length,
        itemBuilder: (context, index) {
          final blockName = groupedData.keys.elementAt(index);
          final indices = groupedData[blockName]!;

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                key: PageStorageKey(blockName), // Evita que se cierren solos al borrar
                iconColor: dorado,
                collapsedIconColor: dorado.withOpacity(0.5),
                title: Text(blockName.toUpperCase(),
                    style: const TextStyle(color: dorado, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 13)),
                subtitle: Text("${indices.length} preguntas en este bloque",
                    style: const TextStyle(color: Colors.white38, fontSize: 10)),
                children: [
                  ...indices.map((originalIndex) {
                    final q = questions[originalIndex];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        title: Text(q.statement,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Colors.white70)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () => _confirmDelete(originalIndex),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}