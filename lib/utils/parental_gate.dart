import 'package:flutter/material.dart';
import 'dart:math';

void showParentalGate(BuildContext context, VoidCallback onSuccess) {
  final random = Random();

  // Generar números entre 3 y 9
  final a = random.nextInt(7) + 3;
  final b = random.nextInt(7) + 3;
  final correctSum = a + b;

  // Generar respuestas incorrectas únicas
  final Set<int> answers = {correctSum};
  while (answers.length < 3) {
    // Generar un número cercano para que no sea tan obvio
    // rango: sum - 5 a sum + 5 (evitando negativos y 0 si se quiere)
    int fake = correctSum + (random.nextInt(10) - 5);
    if (fake > 0 && fake != correctSum) {
      answers.add(fake);
    } else {
      // Fallback simple
      answers.add(random.nextInt(20) + 1);
    }
  }

  // Convertir a lista y mezclar
  final List<int> options = answers.toList()..shuffle();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Solo para Padres 🔒', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Resuelve para continuar:'),
          const SizedBox(height: 16),
          Text(
            '$a + $b = ?',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: options.map((option) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (option == correctSum) {
                    onSuccess();
                  } else {
                    // Feedback visual opcional (SnackBar) si falla
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Respuesta incorrecta. Inténtalo de nuevo.'),
                        duration: Duration(milliseconds: 1000),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  textStyle: const TextStyle(fontSize: 24),
                ),
                child: Text('$option'),
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}
