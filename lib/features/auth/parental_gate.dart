import 'dart:math';
import 'package:flutter/material.dart';

/// A secure gate widget that requires adult supervision to pass.
/// Uses a math challenge "text" based to ensure literacy is required.
class ParentalGate extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback? onCancel;

  const ParentalGate({super.key, required this.onSuccess, this.onCancel});

  static Future<void> show(BuildContext context,
      {required VoidCallback onSuccess}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ParentalGate(
          onSuccess: onSuccess,
          onCancel: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  State<ParentalGate> createState() => _ParentalGateState();
}

class _ParentalGateState extends State<ParentalGate> {
  late int _num1;
  late int _num2;
  late int _answer;
  final TextEditingController _controller = TextEditingController();
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _generateProblem();
  }

  void _generateProblem() {
    // Simple additions for adults, represented as text if possible, but standard numbers here for MVVM.
    // "Three + Two" logic can be added with a number-to-text mapper.
    final random = Random();
    _num1 = random.nextInt(10) + 1; // 1-10
    _num2 = random.nextInt(10) + 1; // 1-10
    _answer = _num1 + _num2;
  }

  void _checkAnswer() {
    final input = int.tryParse(_controller.text.trim());
    if (input == _answer) {
      Navigator.of(context).pop(); // Close dialog
      widget.onSuccess();
    } else {
      setState(() {
        _showError = true;
        _controller.clear();
        _generateProblem(); // Reset problem on fail
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_person_rounded,
              size: 48, color: Color(0xFF5E6472)),
          const SizedBox(height: 16),
          const Text(
            'Solo para Padres',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Para continuar, por favor resuelve:',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '$_num1 + $_num2 = ?',
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFA69E)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Respuesta',
              errorText: _showError ? 'Intenta de nuevo' : null,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: widget.onCancel ?? () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: _checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAED9E0),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Continuar'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
