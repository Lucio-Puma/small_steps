import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

class JonahGame extends StatefulWidget {
  const JonahGame({super.key});

  @override
  State<JonahGame> createState() => _JonahGameState();
}

class _JonahGameState extends State<JonahGame> {
  // Posición de Jonás (en píxeles)
  Offset _jonahPos = const Offset(0, 0);
  bool _isInitialized = false;
  Size _screenSize = Size.zero;

  // Configuración
  final double _jonahSize = 40.0;
  final double _stepSize = 10.0; // Velocidad teclado
  final double _sensorSensitivity = 10.0; // Aumentado para mayor velocidad

  // Estado del juego
  bool _gameWon = false;
  StreamSubscription<UserAccelerometerEvent>? _streamSubscription;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _startSensorListener();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _startSensorListener() {
    _streamSubscription =
        userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      if (_gameWon || !_isInitialized) return;

      // Zona muerta para evitar temblores
      if (event.x.abs() < 0.5 && event.y.abs() < 0.5) return;

      // Accelerometer logic:
      // X: -tiltLeft ... +tiltRight
      // Y: -tiltUp ... +tiltDown (dependiendo de la orientación, asumimos Portrait)
      // Ajustamos: Invertir X para que tilt left mueva a la izquierda
      double dx = -event.x * _sensorSensitivity;
      double dy = event.y * _sensorSensitivity;

      _moveJonah(dx, dy);
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (_gameWon || !_isInitialized) return;

    if (event is KeyDownEvent) {
      double dx = 0;
      double dy = 0;

      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) dx = -_stepSize;
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) dx = _stepSize;
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) dy = -_stepSize;
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) dy = _stepSize;

      if (dx != 0 || dy != 0) {
        _moveJonah(dx, dy);
      }
    }
  }

  void _moveJonah(double dx, double dy) {
    if (!_isInitialized) return;

    final double newX = _jonahPos.dx + dx;
    final double newY = _jonahPos.dy + dy;

    // 1. Limites de pantalla (Clamp)
    final double clampedX = newX.clamp(0.0, _screenSize.width - _jonahSize);
    final double clampedY = newY.clamp(0.0, _screenSize.height - _jonahSize);

    // 2. Colisiones con Paredes
    Rect newRect = Rect.fromLTWH(clampedX, clampedY, _jonahSize, _jonahSize);

    // Lista de paredes actual
    final walls = _getWalls(_screenSize);
    bool collides = false;
    for (final wall in walls) {
      if (newRect.overlaps(wall)) {
        collides = true;
        break;
      }
    }

    if (!collides) {
      setState(() {
        _jonahPos = Offset(clampedX, clampedY);
      });
      _checkVictory();
    }
  }

  void _checkVictory() {
    // La salida está arriba del todo (zona segura)
    // Digamos, el 10% superior
    if (_jonahPos.dy < 50) {
      setState(() {
        _gameWon = true;
      });
      _showVictoryDialog();
    }
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('¡Jonás Libre!'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wb_sunny, size: 60, color: Colors.orange),
            SizedBox(height: 16),
            Text('¡Has salido de la ballena!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Exit game
            },
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetGame();
            },
            child: const Text('Jugar Otra Vez'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _gameWon = false;
      // Reiniciar posición al fondo centro
      _jonahPos = Offset(
        (_screenSize.width - _jonahSize) / 2,
        _screenSize.height - 100,
      );
    });
  }

  // Definición del Nivel (Paredes relativas al tamaño)
  List<Rect> _getWalls(Size size) {
    if (size == Size.zero) return [];

    // Paredes formando un Zig-Zag simple
    return [
      // Pared Horizontal 1 (Abajo)
      Rect.fromLTWH(0, size.height * 0.75, size.width * 0.7, 40),

      // Pared Horizontal 2 (Medio)
      Rect.fromLTWH(size.width * 0.3, size.height * 0.5, size.width * 0.7, 40),

      // Pared Horizontal 3 (Arriba)
      Rect.fromLTWH(0, size.height * 0.25, size.width * 0.6, 40),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Requerir foco para teclado
    if (!_focusNode.hasFocus) _focusNode.requestFocus();

    return Scaffold(
      backgroundColor:
          const Color(0xFF4A148C), // Morado oscuro (Interior Ballena)
      appBar: AppBar(
        title: const Text('Jonás y la Ballena'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            _screenSize = Size(constraints.maxWidth, constraints.maxHeight);

            // Inicializar posición una sola vez
            if (!_isInitialized) {
              _jonahPos = Offset(
                (_screenSize.width - _jonahSize) / 2,
                _screenSize.height - 80, // Empezar abajo
              );
              // Post-frame callback para evitar error de setState durante build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _isInitialized = true;
                });
              });
            }

            final walls = _getWalls(_screenSize);

            return Stack(
              children: [
                // 1. La Salida (Sol)
                const Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Icon(Icons.wb_sunny,
                        size: 60, color: Colors.yellowAccent),
                  ),
                ),

                // 2. Paredes
                ...walls.map((rect) => Positioned(
                      left: rect.left,
                      top: rect.top,
                      width: rect.width,
                      height: rect.height,
                      child: Container(
                        decoration: BoxDecoration(
                            color: const Color(0xFF880E4F), // Carne oscura
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.red.shade900, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 5,
                                  offset: Offset(2, 2))
                            ]),
                      ),
                    )),

                // 3. Jonás
                Positioned(
                  left: _jonahPos.dx,
                  top: _jonahPos.dy,
                  child: Container(
                    width: _jonahSize,
                    height: _jonahSize,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.blueAccent, blurRadius: 10)
                        ]),
                    child:
                        const Icon(Icons.directions_walk, color: Colors.blue),
                  ),
                ),

                // Mensaje de ayuda PC
                const Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Text(
                    "Usa INCLINACIÓN o TECLADO para moverte",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white30, fontSize: 12),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
