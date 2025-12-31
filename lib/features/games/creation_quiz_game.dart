import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreationQuizGame extends StatefulWidget {
  const CreationQuizGame({super.key});

  @override
  State<CreationQuizGame> createState() => _CreationQuizGameState();
}

class _CreationQuizGameState extends State<CreationQuizGame> {
  // Datos del Quiz
  final List<QuizQuestion> _questions = [
    QuizQuestion(
      text: 'Dios dijo: "Hágase la Luz"',
      correctFace: '☀️',
      options: ['☀️', '🚗', '🍕'],
    ),
    QuizQuestion(
      text: 'Dios creó el cielo y el mar',
      correctFace: '☁️',
      options: ['👟', '☁️', '🧱'],
    ),
    QuizQuestion(
      text: 'Dios creó las plantas y árboles',
      correctFace: '🌳',
      options: ['🌳', '🥤', '📱'],
    ),
    QuizQuestion(
      text: 'Dios creó la luna y las estrellas',
      correctFace: '🌙',
      options: ['🕶️', '🏈', '🌙'],
    ),
    QuizQuestion(
      text: 'Dios creó a los peces',
      correctFace: '🐟',
      options: ['🐱', '🐟', '🌵'],
    ),
    QuizQuestion(
      text: 'Dios creó a los animales',
      correctFace: '🦁',
      options: ['🚗', '⏰', '🦁'],
    ),
  ];

  int _currentIndex = 0;
  bool _isAnswerLocked = false;
  bool _isGameWon = false;

  void _restartGame() {
    setState(() {
      _currentIndex = 0;
      _isAnswerLocked = false;
      _isGameWon = false;
      _questions.shuffle(); // Variar orden de preguntas si se desea
    });
  }

  void _handleAnswer(String selectedEmoji) async {
    if (_isAnswerLocked) return;

    final currentQuestion = _questions[_currentIndex];

    if (selectedEmoji == currentQuestion.correctFace) {
      // Correcto!
      HapticFeedback.mediumImpact();
      setState(() {
        _isAnswerLocked = true;
      });

      // Esperar animación y pasar
      await Future.delayed(const Duration(milliseconds: 1000));

      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _isAnswerLocked = false;
        });
      } else {
        setState(() {
          _isGameWon = true;
        });
        HapticFeedback.heavyImpact();
      }
    } else {
      // Incorrecto (Feedback visual manejado por el botón individual)
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE), // Azul cielo muy claro
      appBar: AppBar(
        title: const Text('La Creación'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0277BD) // Azul oscuro
            ),
        iconTheme: const IconThemeData(color: Color(0xFF0277BD)),
      ),
      body: _isGameWon ? _buildVictoryScreen() : _buildQuizBody(),
    );
  }

  Widget _buildQuizBody() {
    final question = _questions[_currentIndex];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Progreso
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            backgroundColor: Colors.white,
            color: Colors.lightBlueAccent,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 40),

          // Pregunta
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ]),
            child: Text(
              question.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0277BD),
              ),
            ),
          ),

          const Spacer(),

          // Opciones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: question.options.map((emoji) {
              return _AnswerButton(
                emoji: emoji,
                isCorrect: emoji == question.correctFace,
                onTap: () => _handleAnswer(emoji),
                disabled: _isAnswerLocked,
              );
            }).toList(),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildVictoryScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.public, size: 100, color: Colors.green),
          const SizedBox(height: 24),
          const Text(
            '¡Mundo Creado!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0277BD),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '¡Has aprendido muy bien!',
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _restartGame,
            icon: const Icon(Icons.refresh),
            label: const Text('Jugar Otra Vez'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FC3F7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}

class _AnswerButton extends StatefulWidget {
  final String emoji;
  final bool isCorrect;
  final VoidCallback onTap;
  final bool disabled;

  const _AnswerButton({
    required this.emoji,
    required this.isCorrect,
    required this.onTap,
    required this.disabled,
  });

  @override
  State<_AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<_AnswerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Color _bgColor = Colors.white;
  double _scale = 1.0;
  Offset _shakeOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (widget.disabled) return;

    if (widget.isCorrect) {
      // Animación Correcto: Escala y color verde
      setState(() {
        _bgColor = Colors.greenAccent.shade100;
        _scale = 1.3;
      });
      widget.onTap(); // Notifica al padre

      // Reset después de un tiempo (si se reutiliza el widget)
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        setState(() {
          _bgColor = Colors.white;
          _scale = 1.0;
        });
      }
    } else {
      // Animación Incorrecto: Shake y rojo
      setState(() {
        _bgColor = Colors.redAccent.shade100;
      });

      // Simple shake manual
      for (int i = 0; i < 3; i++) {
        if (!mounted) break;
        setState(() => _shakeOffset = const Offset(-5, 0));
        await Future.delayed(const Duration(milliseconds: 50));
        setState(() => _shakeOffset = const Offset(5, 0));
        await Future.delayed(const Duration(milliseconds: 50));
      }
      setState(() => _shakeOffset = Offset.zero);

      widget.onTap(); // Notifica al padre (para haptic, etc)

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() => _bgColor = Colors.white);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: _shakeOffset,
      child: Transform.scale(
        scale: _scale,
        child: GestureDetector(
          onTap: _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3))
              ],
              border: Border.all(color: Colors.blue.shade100, width: 2),
            ),
            child: Center(
              child: Text(
                widget.emoji,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuizQuestion {
  final String text;
  final String correctFace;
  final List<String> options;

  QuizQuestion(
      {required this.text, required this.correctFace, required this.options});
}
