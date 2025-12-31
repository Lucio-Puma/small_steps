import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback

class NoahArkGame extends StatefulWidget {
  const NoahArkGame({super.key});

  @override
  State<NoahArkGame> createState() => _NoahArkGameState();
}

class _NoahArkGameState extends State<NoahArkGame> {
  // Configuración del juego
  final List<String> _animalEmojis = ['🦁', '🐘', '🐑', '🕊️', '🦒', '🦓'];

  List<MemoryCard> _cards = [];
  List<int> _flippedIndices = [];
  bool _isProcessing =
      false; // Bloquea la interacción mientras se verifica pareja
  bool _isGameWon = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    // 1. Duplicar la lista para hacer parejas
    List<String> gameEmojis = [..._animalEmojis, ..._animalEmojis];
    // 2. Barajar
    gameEmojis.shuffle();

    setState(() {
      _cards = gameEmojis.map((emoji) => MemoryCard(emoji: emoji)).toList();
      _flippedIndices = [];
      _isProcessing = false;
      _isGameWon = false;
    });
  }

  void _onCardTap(int index) {
    if (_isProcessing || _cards[index].isFlipped || _cards[index].isMatched)
      return;

    setState(() {
      _cards[index].isFlipped = true;
      _flippedIndices.add(index);
    });

    HapticFeedback.lightImpact(); // Feedback táctil suave

    if (_flippedIndices.length == 2) {
      _checkForMatch();
    }
  }

  void _checkForMatch() async {
    _isProcessing = true;
    final index1 = _flippedIndices[0];
    final index2 = _flippedIndices[1];

    if (_cards[index1].emoji == _cards[index2].emoji) {
      // ¡Pareja encontrada!
      HapticFeedback.mediumImpact(); // Feedback más fuerte
      setState(() {
        _cards[index1].isMatched = true;
        _cards[index2].isMatched = true;
        _flippedIndices.clear();
        _isProcessing = false;
      });
      _checkForWin();
    } else {
      // No coinciden, esperar y ocultar
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        setState(() {
          _cards[index1].isFlipped = false;
          _cards[index2].isFlipped = false;
          _flippedIndices.clear();
          _isProcessing = false;
        });
      }
    }
  }

  void _checkForWin() {
    if (_cards.every((card) => card.isMatched)) {
      setState(() {
        _isGameWon = true;
      });
      HapticFeedback.heavyImpact(); // Celebración táctil
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF0F4C3), // Fondo verde suave (Naturaleza)
      appBar: AppBar(
        title: const Text('El Arca de Noé'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D4037) // Marrón madera
            ),
        iconTheme: const IconThemeData(color: Color(0xFF5D4037)),
      ),
      body: _isGameWon ? _buildVictoryScreen() : _buildGameBoard(),
    );
  }

  Widget _buildGameBoard() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '¡Encuentra las parejas!',
            style: TextStyle(
                fontSize: 20,
                color: Colors.brown[700],
                fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 columnas
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                return _buildCardItem(index);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardItem(int index) {
    final card = _cards[index];
    final isVisible = card.isFlipped || card.isMatched;

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isVisible
              ? Colors.white
              : const Color(0xFFAED581), // Verde anverso / Blanco reverso
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(2, 2),
            )
          ],
          border: isVisible
              ? Border.all(color: const Color(0xFFAED581), width: 4)
              : null,
        ),
        child: Center(
          child: isVisible
              ? Text(
                  card.emoji,
                  style: const TextStyle(fontSize: 48),
                )
              : const Icon(
                  Icons.question_mark_rounded,
                  color: Colors.white,
                  size: 40,
                ),
        ),
      ),
    );
  }

  Widget _buildVictoryScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🎉',
            style: TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 16),
          const Text(
            '¡Lo lograste!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Todos los animales están a salvo.',
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _startNewGame,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Jugar Otra Vez'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFAED581),
              foregroundColor: const Color(0xFF33691E),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          )
        ],
      ),
    );
  }
}

class MemoryCard {
  final String emoji;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.emoji,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
