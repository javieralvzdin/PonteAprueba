import 'package:flutter/material.dart';
import 'services/repository_service.dart';
import 'models/question.dart';
import 'screens/manage_questions_screen.dart';
import 'screens/exam_setup_screen.dart'; // IMPORTANTE
import 'screens/ai_creation_screen.dart';

const Color kDoradoBodoni = Color(0xFFD4AF37);
const Color kFondoNegro = Color(0xFF0F1216);
const String kFontFamily = 'Bodoni MT';

void main() => runApp(const ExaminatorApp());

class ExaminatorApp extends StatelessWidget {
  const ExaminatorApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PonteAprueba',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: kFontFamily,
        scaffoldBackgroundColor: kFondoNegro,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontFamily: kFontFamily, color: kDoradoBodoni, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kDoradoBodoni, foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          labelStyle: const TextStyle(color: kDoradoBodoni),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RepositoryService _repo = RepositoryService();
  bool _initialized = false;

  @override
  void initState() { super.initState(); _preparar(); }

  Future<void> _preparar() async {
    await _repo.load();
    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const Scaffold(body: Center(child: CircularProgressIndicator(color: kDoradoBodoni)));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
          child: Column(
            children: [
              const Icon(Icons.auto_awesome, color: kDoradoBodoni, size: 80),
              const SizedBox(height: 20),
              const Text('PonteAprueba', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: kDoradoBodoni)),
              const Text('M M X X V', style: TextStyle(color: kDoradoBodoni, letterSpacing: 10, fontSize: 10)),
              const SizedBox(height: 80),

              ElevatedButton.icon(
                onPressed: _repo.getAll().isEmpty ? null : () => Navigator.push(context, MaterialPageRoute(builder: (c) => ExamSetupScreen(repo: _repo))),
                icon: const Icon(Icons.play_arrow_rounded), label: const Text('MODO EXAMEN'),
              ),
              const SizedBox(height: 20),

              OutlinedButton.icon(
                onPressed: () async {
                  final List<Question>? nuevas = await Navigator.push(context, MaterialPageRoute(builder: (c) => const AICreationScreen()));
                  if (nuevas != null) {
                    for (var q in nuevas) { _repo.addQuestion(q); }
                    await _repo.save(); setState(() {});
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: kDoradoBodoni, side: const BorderSide(color: kDoradoBodoni),
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                ),
                icon: const Icon(Icons.auto_awesome), label: const Text('IMPORTAR APUNTES'),
              ),
              const SizedBox(height: 20),

              TextButton.icon(
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (c) => ManageQuestionsScreen(repo: _repo)));
                  setState(() {});
                },
                icon: const Icon(Icons.folder_open, color: Colors.white38),
                label: const Text('GESTIONAR PREGUNTAS', style: TextStyle(color: Colors.white38)),
              ),
              const SizedBox(height: 40),
              Text('PREGUNTAS TOTALES: ${_repo.getAll().length}', style: const TextStyle(color: Colors.white10, fontSize: 10, letterSpacing: 2)),
            ],
          ),
        ),
      ),
    );
  }
}