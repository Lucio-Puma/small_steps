import 'package:flutter/material.dart';

class GardenScreen extends StatelessWidget {
  final List<String> plants;

  const GardenScreen({super.key, required this.plants});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Verde suave
      appBar: AppBar(
        title: const Text('Mi Jardín del Edén'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E7D32), // Verde bosque
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2E7D32)),
      ),
      body: plants.isEmpty
          ? _buildEmptyState(context)
          : _buildGardenGrid(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_florist_outlined,
              size: 100, color: Colors.grey),
          const SizedBox(height: 24),
          Text(
            'Tu jardín está esperando...',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Completa todas tus tareas del día para ganar una nueva planta.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGardenGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: plants.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Center(
              child: Text(
                plants[index],
                style: const TextStyle(fontSize: 32),
              ),
            ),
          );
        },
      ),
    );
  }
}
