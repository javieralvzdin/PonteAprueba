import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    // Cálculo de la nota sobre 10
    final double nota = total > 0 ? (score * 10 / total) : 0.0;
    final bool aprobado = nota >= 5.0;
    const Color dorado = Color(0xFFD4AF37);

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono dinámico según resultado
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: dorado, width: 2),
              ),
              child: Icon(
                aprobado ? Icons.auto_awesome : Icons.menu_book,
                size: 80,
                color: dorado,
              ),
            ),
            const SizedBox(height: 40),

            const Text(
                'CALIFICACIÓN FINAL',
                style: TextStyle(
                    letterSpacing: 4,
                    color: dorado,
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                )
            ),
            const SizedBox(height: 10),

            // Nota grande con fuente Bodoni
            Text(
                nota.toStringAsFixed(1),
                style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Bodoni MT',
                    color: Colors.white
                )
            ),

            Text(
                '$score aciertos de $total posibles',
                style: const TextStyle(
                    color: Colors.white38,
                    letterSpacing: 1.5
                )
            ),

            const SizedBox(height: 60),

            // Botón de Compartir con Share Plus
            ElevatedButton.icon(
              onPressed: () {
                Share.share(
                    'He completado mi examen en PonteAprueba con una nota de ${nota.toStringAsFixed(1)}/10. ¡Intenta superarme!'
                );
              },
              icon: const Icon(Icons.share_outlined),
              label: const Text('COMPARTIR'),
            ),

            const SizedBox(height: 15),

            // Botón para volver al inicio del todo
            OutlinedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              style: OutlinedButton.styleFrom(
                foregroundColor: dorado,
                side: const BorderSide(color: dorado),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
              ),
              child: const Text('VOLVER AL INICIO'),
            ),
          ],
        ),
      ),
    );
  }
}