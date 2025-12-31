import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JosephTunicGame extends StatefulWidget {
  const JosephTunicGame({super.key});

  @override
  State<JosephTunicGame> createState() => _JosephTunicGameState();
}

class _JosephTunicGameState extends State<JosephTunicGame> {
  // Colores de la túnica (targets)
  final List<Color> _targetColors = [
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.yellow,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
  ];

  // Estado de completado de cada franja
  late List<bool> _isColored;
  bool _gameWon = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _isColored = List.filled(_targetColors.length, false);
      _gameWon = false;
    });
  }

  void _checkVictory() {
    if (_isColored.every((element) => element)) {
      setState(() {
        _gameWon = true;
      });
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0), // Fondo crema suave
      appBar: AppBar(
        title: const Text('La Túnica de José'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFEF6C00) // Naranja oscuro
            ),
        iconTheme: const IconThemeData(color: Color(0xFFEF6C00)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startNewGame,
            tooltip: 'Reiniciar',
          )
        ],
      ),
      body: _gameWon ? _buildVictoryScreen() : _buildGameArea(),
    );
  }

  Widget _buildGameArea() {
    return Column(
      children: [
        // Área de la Túnica (Destino)
        Expanded(
          flex: 2,
          child: Center(
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.brown, width: 2),
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_targetColors.length, (index) {
                  return _buildTunicStripe(index);
                }),
              ),
            ),
          ),
        ),

        // Área de Parches (Origen)
        Expanded(
          flex: 1,
          child: Container(
            color: const Color(0xFFFFE0B2), // Naranja muy claro
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Arrastra el color correcto',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: _targetColors.asMap().entries.map((entry) {
                    // Solo mostramos los parches que aún no se han colocado
                    // O podemos dejarlos infinitos. Vamos a dejarlos disponibles siempre.
                    return _buildDraggablePatch(entry.value);
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTunicStripe(int index) {
    final color = _targetColors[index];
    final isDone = _isColored[index];

    return DragTarget<Color>(
      onWillAccept: (droppedColor) => droppedColor == color && !isDone,
      onAccept: (droppedColor) {
        setState(() {
          _isColored[index] = true;
        });
        HapticFeedback.mediumImpact();
        _checkVictory();
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          height: 50,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isDone
                ? color
                : Colors.grey[200], // Gris si no está pintado, Color si sí
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: candidateData.isNotEmpty
                  ? color
                  : Colors.transparent, // Highlight al arrastrar
              width: 2,
            ),
            boxShadow: isDone
                ? [
                    const BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        offset: Offset(0, 1))
                  ]
                : null,
          ),
          child: isDone
              ? const Icon(Icons.check, color: Colors.white)
              : candidateData.isNotEmpty
                  ? Icon(Icons.download, color: color.withOpacity(0.5))
                  : null,
        );
      },
    );
  }

  Widget _buildDraggablePatch(Color color) {
    return Draggable<Color>(
      data: color,
      feedback: _buildPatchShape(color, isDragging: true),
      childWhenDragging: _buildPatchShape(color, isGhost: true),
      child: _buildPatchShape(color),
    );
  }

  Widget _buildPatchShape(Color color,
      {bool isDragging = false, bool isGhost = false}) {
    double size = isDragging ? 70 : 60;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isGhost ? color.withOpacity(0.2) : color,
        shape: BoxShape.circle,
        boxShadow: !isGhost && !isDragging
            ? [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2))
              ]
            : null,
      ),
      child: isDragging
          ? const Icon(Icons.touch_app, color: Colors.white30, size: 30)
          : null,
    );
  }

  Widget _buildVictoryScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.palette, size: 100, color: Colors.deepOrange),
          const SizedBox(height: 24),
          const Text(
            '¡Túnica Completa!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEF6C00),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '¡Qué hermosa ha quedado!',
            style: TextStyle(fontSize: 18, color: Colors.brown),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _startNewGame,
            icon: const Icon(Icons.refresh),
            label: const Text('Pintar Otra Vez'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB74D),
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
