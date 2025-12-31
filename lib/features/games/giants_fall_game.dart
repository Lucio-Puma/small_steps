import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GiantsFallGame extends StatefulWidget {
  const GiantsFallGame({super.key});

  @override
  State<GiantsFallGame> createState() => _GiantsFallGameState();
}

class _GiantsFallGameState extends State<GiantsFallGame> {
  // Sensor stream
  StreamSubscription<UserAccelerometerEvent>? _streamSubscription;

  // Game State
  double _energy = 0.0; // 0.0 to 1.0
  bool _isGameWon = false;
  bool _isSafetyAcknowledged = false;

  // Threshold to detect "Active Movement" vs "Sitting still"
  // We want kids to move/shake their arm but not throw the phone.
  final double _shakeThreshold = 15.0;

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _energy = 0.0;
      _isGameWon = false;
    });

    // Start Listening to Sensor
    _streamSubscription =
        userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      if (_isGameWon) return;

      // Calculate total acceleration magnitude
      double magnitude =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      // If movement is energetic enough
      if (magnitude > 2.0) {
        // Low threshold for kids
        setState(() {
          // Charge up!
          _energy += 0.005; // Slow charge, requires sustained movement
          if (_energy >= 1.0) {
            _energy = 1.0;
            // Ready to throw! (Auto-trigger or button?)
            // Let's require a final TAP to release for accuracy training + motor control (Stop & Act)
          }
        });
      }
    });
  }

  void _launchStone() {
    if (_energy >= 1.0) {
      _streamSubscription?.pause();
      setState(() {
        _isGameWon = true;
      });
      HapticFeedback.heavyImpact();
    } else {
      // Feedback: Not ready yet
      HapticFeedback.selectionClick();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('¡Aún falta fuerza! ¡Gira el brazo!'),
            duration: Duration(milliseconds: 500)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9C4), // Amarillo pálido (Desierto)
      appBar: AppBar(
        title: const Text('David vs Goliat'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D4037)),
        iconTheme: const IconThemeData(color: Color(0xFF5D4037)),
      ),
      body: !_isSafetyAcknowledged
          ? _buildSafetyWarning()
          : _isGameWon
              ? _buildVictoryScreen()
              : _buildGameLoop(),
    );
  }

  Widget _buildSafetyWarning() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 80, color: Colors.orange),
          const SizedBox(height: 24),
          const Text(
            '¡Atención Papás!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Este juego requiere movimiento físico.'
            '\nAsegúrate de que tu hijo sostenga el teléfono firmemente con ambas manos o ayúdale.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isSafetyAcknowledged = true;
              });
              _startGame();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Entendido, ¡A Jugar!'),
          )
        ],
      ),
    );
  }

  Widget _buildGameLoop() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '¡Carga tu honda!',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown),
        ),
        const SizedBox(height: 8),
        const Text(
          'Mueve el brazo circularmente',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 48),

        // The Sling "Avatar"
        Transform.rotate(
          angle: _energy * 2 * pi * 4, // Spin based on energy
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.brown[300],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.brown, width: 4),
            ),
            child: const Center(
              child: Text('🪨', style: TextStyle(fontSize: 60)),
            ),
          ),
        ),

        const SizedBox(height: 48),

        // Progress Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LinearProgressIndicator(
              value: _energy,
              minHeight: 30,
              backgroundColor: Colors.brown[100],
              valueColor: AlwaysStoppedAnimation<Color>(
                  _energy >= 1.0 ? Colors.green : Colors.orange),
            ),
          ),
        ),

        const SizedBox(height: 48),

        // Launch Button (Only active when full)
        Opacity(
          opacity: _energy >= 1.0 ? 1.0 : 0.3,
          child: ElevatedButton.icon(
            onPressed: _energy >= 1.0 ? _launchStone : null,
            icon: const Icon(Icons.gps_fixed),
            label: const Text('¡LANZAR!'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              textStyle:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVictoryScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🤕', style: TextStyle(fontSize: 100)), // Goliath hit
          const SizedBox(height: 16),
          const Text(
            '¡GIGANTE CAÍDO!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'La fe mueve montañas... ¡y gigantes!',
            style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _startGame,
            icon: const Icon(Icons.refresh),
            label: const Text('Jugar Otra Vez'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          )
        ],
      ),
    );
  }
}
