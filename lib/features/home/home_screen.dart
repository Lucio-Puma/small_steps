import 'package:flutter/material.dart';
import 'package:small_steps/features/auth/parental_gate.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background Layer - "The Garden"
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE0F7FA),
                      Color(0xFFF1F8E9)
                    ], // Sky to Grass
                  ),
                ),
              ),
            ),

            // Content Layer
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // App Title / Logo Area
                      const Text(
                        'Pequeños Pasos',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5E6472)),
                      ),
                      // Settings Button (Protected)
                      IconButton(
                        icon: const Icon(Icons.settings_rounded,
                            size: 32, color: Color(0xFF5E6472)),
                        onPressed: () {
                          ParentalGate.show(context, onSuccess: () {
                            // Navigate to Settings Page
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Acceso a Configuración de Padres Concedido')),
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Games Carousel / Map
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const Text(
                        'Elige una Aventura',
                        style:
                            TextStyle(fontSize: 20, color: Color(0xFF78909C)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Game Card 1: Noah
                      _GameCard(
                        title: 'El Arca de Noé',
                        color: const Color(0xFFAED9E0), // Pastel Blue
                        icon: Icons.pets_rounded,
                        description: 'Encuentra las parejas',
                        onTap: () {
                          // Navigate to Game 1
                        },
                      ),

                      const SizedBox(height: 16),

                      // Game Card 2: Joseph
                      _GameCard(
                        title: 'La Túnica de José',
                        color: const Color(0xFFFFA69E), // Pastel Red/Pink
                        icon: Icons.palette_rounded,
                        description: 'Colorea su traje',
                        onTap: () {
                          // Navigate to Game 2
                        },
                      ),

                      const SizedBox(height: 16),

                      // Game Card 3: David
                      _GameCard(
                        title: 'David y Goliat',
                        color: const Color(0xFFFFD54F), // Pastel Yellow
                        icon: Icons
                            .fitness_center_rounded, // Represents strength/motion
                        description: '¡Muévete valiente!',
                        onTap: () {
                          // Navigate to Game 3
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final String description;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.color,
    required this.icon,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon / Image Area
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white54,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: Colors.black54),
              ),
            ),

            // Text Area
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),

            // Play Button Indicator
            const Padding(
              padding: EdgeInsets.only(right: 24.0),
              child: Icon(Icons.play_circle_fill_rounded,
                  size: 40, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
