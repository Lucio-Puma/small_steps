import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:small_steps/features/games/memory_game.dart';
import 'package:small_steps/features/games/joseph_tunic_game.dart';
import 'package:small_steps/features/games/giants_fall_game.dart';
import 'package:small_steps/features/games/creation_quiz_game.dart';
import 'package:small_steps/features/games/jonah_game.dart';
import 'package:small_steps/features/garden/garden_screen.dart';
import 'package:small_steps/services/tts_service.dart';
import 'package:small_steps/utils/parental_gate.dart';
import 'package:small_steps/services/notification_service.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await NotificationService().requestPermissions();
  runApp(const SmallStepsApp());
}

class SmallStepsApp extends StatelessWidget {
  const SmallStepsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Small Steps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF40E0D0), // Turquesa
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          headlineMedium:
              TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

/// Modelo de datos para un "Paso"
class StepItem {
  final String title;
  final DateTime date;
  final bool isCompleted;
  final int? iconCodePoint; // Nuevo campo para icono personalizado

  StepItem({
    required this.title,
    required this.date,
    this.isCompleted = false,
    this.iconCodePoint,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'date': date.toIso8601String(),
        'isCompleted': isCompleted,
        'iconCodePoint': iconCodePoint,
      };

  factory StepItem.fromJson(Map<String, dynamic> json) {
    return StepItem(
      title: json['title'],
      date: DateTime.parse(json['date']),
      isCompleted: json['isCompleted'] ?? false,
      iconCodePoint: json['iconCodePoint'],
    );
  }

  StepItem copyWith({
    String? title,
    DateTime? date,
    bool? isCompleted,
    int? iconCodePoint,
  }) {
    return StepItem(
      title: title ?? this.title,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const StepsView(),
    const GamesView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.directions_walk_outlined),
            selectedIcon: Icon(Icons.directions_walk),
            label: 'Mis Pasos',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports),
            label: 'Juegos',
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// VISTA DE PASOS (Habit Tracker)
// --------------------------------------------------------------------------
class StepsView extends StatefulWidget {
  const StepsView({super.key});

  @override
  State<StepsView> createState() => _StepsViewState();
}

class _StepsViewState extends State<StepsView> {
  List<StepItem> _steps = [];
  List<String> _gardenPlants = [];
  String? _lastRewardDate;

  double _dailyProgress = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Inicializar el servicio TTS (asegurando configuración)
    TtsService();
    // Pedir permisos de notificación
    NotificationService().requestPermissions();
    _loadData();
  }

  @override
  void dispose() {
    // Detener cualquier audio pendiente al salir de esta vista/pestaña
    TtsService().stop();
    super.dispose();
  }

  void _sortSteps() {
    // Ordenamos por hora y minuto
    _steps.sort((a, b) {
      int timeA = a.date.hour * 60 + a.date.minute;
      int timeB = b.date.hour * 60 + b.date.minute;
      return timeA.compareTo(timeB);
    });
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stepsJson = prefs.getStringList('steps_key');
    final List<String>? gardenJson = prefs.getStringList('garden_plants');
    final String? lastReward = prefs.getString('last_reward_date');

    if (stepsJson != null) {
      if (mounted) {
        setState(() {
          _steps = stepsJson
              .map((item) => StepItem.fromJson(jsonDecode(item)))
              .toList();
          _gardenPlants = gardenJson ?? [];
          _lastRewardDate = lastReward;

          _sortSteps(); // Ordenar siempre al cargar
          _recalculateProgress();
          _isLoading = false;
        });
      }
    } else {
      // Si no existen datos PREVIOS, cargamos los mock data
      await _populateMockData();
    }
  }

  Future<void> _populateMockData() async {
    final prefs = await SharedPreferences.getInstance();
    // NOTA: No borramos aquí (prefs.clear) para respetar la lógica de "Primera Vez"
    // Solo si el usuario fuerza un borrado manual llamaremos a _clearSteps que sí borra.

    final now = DateTime.now();
    DateTime atTime(int hour, int minute) {
      return DateTime(now.year, now.month, now.day, hour, minute);
    }

    final List<StepItem> mockItems = [
      // MAÑANA
      StepItem(
        title: "Dar gracias al despertar",
        date: atTime(7, 0),
        iconCodePoint: Icons.wb_sunny_rounded.codePoint,
      ),
      StepItem(
        title: "Lavarse los dientes",
        date: atTime(7, 15),
        iconCodePoint: Icons.water_drop.codePoint,
      ),
      StepItem(
        title: "Vestirse solo",
        date: atTime(7, 30),
        iconCodePoint: Icons.checkroom.codePoint,
      ),

      // MEDIODÍA
      StepItem(
        title: "Comerse todas las verduras",
        date: atTime(13, 0),
        iconCodePoint: Icons.restaurant.codePoint,
      ),
      StepItem(
        title: "Ayudar a poner la mesa",
        date: atTime(13, 30),
        iconCodePoint: Icons.kitchen.codePoint,
      ),
      StepItem(
        title: "Hacer la siesta",
        date: atTime(14, 0),
        iconCodePoint: Icons.bed.codePoint,
      ),

      // TARDE
      StepItem(
        title: "Jugar y compartir",
        date: atTime(16, 0),
        iconCodePoint: Icons.toys.codePoint,
      ),
      StepItem(
        title: "Recoger los juguetes",
        date: atTime(17, 30),
        iconCodePoint: Icons.cleaning_services.codePoint,
      ),
      StepItem(
        title: "Hacer un dibujo",
        date: atTime(18, 0),
        iconCodePoint: Icons.brush.codePoint,
      ),

      // NOCHE
      StepItem(
        title: "Ponerse la pijama",
        date: atTime(19, 30),
        iconCodePoint: Icons.accessibility_new.codePoint,
      ),
      StepItem(
        title: "Leer historia bíblica",
        date: atTime(20, 0),
        iconCodePoint: Icons.menu_book.codePoint,
      ),
      StepItem(
        title: "Orar antes de dormir",
        date: atTime(20, 15),
        iconCodePoint: Icons.star.codePoint,
      ),
    ];

    if (mounted) {
      setState(() {
        _steps = mockItems;
        _sortSteps();
        _recalculateProgress();
        _isLoading = false;
      });
    }

    // Guardamos la nueva lista
    final List<String> stepsJson =
        mockItems.map((step) => jsonEncode(step.toJson())).toList();
    await prefs.setStringList('steps_key', stepsJson);
  }

  Future<void> _saveData() async {
    _sortSteps(); // Aseguramos orden antes de guardar
    final prefs = await SharedPreferences.getInstance();
    final List<String> stepsJson =
        _steps.map((step) => jsonEncode(step.toJson())).toList();
    await prefs.setStringList('steps_key', stepsJson);
  }

  void _recalculateProgress() {
    if (_steps.isEmpty) {
      _dailyProgress = 0.0;
    } else {
      final completed = _steps.where((s) => s.isCompleted).length;
      _dailyProgress = (completed / _steps.length).clamp(0.0, 1.0);
    }
  }

  // Opens modal for adding OR editing
  void _openTaskModal({StepItem? existingItem, int? index}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return AddTaskModal(
          existingItem: existingItem,
          onTaskSaved: (StepItem newItem) {
            setState(() {
              if (index != null) {
                // Editing
                _steps[index] = newItem;
              } else {
                // Adding
                _steps.add(newItem);
              }
              _recalculateProgress();
            });

            _saveData();
          },
          onTaskDeleted: () {
            if (index != null) {
              setState(() {
                _steps.removeAt(index);
                _recalculateProgress();
              });
              _saveData();
            }
          },
        );
      },
    );
  }

  void _toggleStep(int index) {
    setState(() {
      _steps[index] = _steps[index].copyWith(
        isCompleted: !_steps[index].isCompleted,
      );
      _recalculateProgress();
    });

    // Feedback sonoro si se completa
    if (_steps[index].isCompleted) {
      TtsService().speak("¡Muy bien!");
      _checkDailyGoal();
    }

    _saveData();
  }

  void _checkDailyGoal() {
    // 1. Verificar si el progreso es 100%
    final completedCount = _steps.where((s) => s.isCompleted).length;
    final isAllDone = _steps.isNotEmpty && completedCount == _steps.length;

    if (!isAllDone) return;

    // 2. Verificar fecha
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";

    if (_lastRewardDate == todayStr) return; // Ya ganó hoy

    // 3. ¡Premio!
    final List<String> possiblePlants = [
      '🌱',
      '🌻',
      '🌹',
      '🌴',
      '🌵',
      '🌲',
      '🍄',
      '🌷',
      '🌿',
      '🍀',
      '🍁',
      '🍇'
    ];
    final randomPlant = possiblePlants[Random().nextInt(possiblePlants.length)];

    setState(() {
      _gardenPlants.add(randomPlant);
      _lastRewardDate = todayStr;
    });

    _saveGardenData();
    _showRewardDialog(randomPlant);
  }

  Future<void> _saveGardenData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('garden_plants', _gardenPlants);
    if (_lastRewardDate != null) {
      await prefs.setString('last_reward_date', _lastRewardDate!);
    }
  }

  void _showRewardDialog(String plant) {
    TtsService()
        .speak("¡Felicidades! Ganaste una nueva planta para tu jardín.");
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¡Felicidades!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¡Has completado todas tus tareas!'),
            const SizedBox(height: 16),
            Text(plant, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text('Se ha añadido a tu Jardín del Edén.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _openGarden();
            },
            child: const Text('Ir al Jardín'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('¡Genial!'),
          ),
        ],
      ),
    );
  }

  void _openGarden() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GardenScreen(plants: _gardenPlants),
      ),
    );
  }

  void _clearSteps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpiamos persistencia
    await _populateMockData(); // Regeneramos defaults
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Lista reiniciada con éxito!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Small Steps'),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_florist, color: Colors.green),
            tooltip: "Mi Jardín",
            onPressed: _openGarden,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: "Reiniciar Lista",
            onPressed: _clearSteps, // Reinicia en vez de borrar todo
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildProgressSection(context),
                const SizedBox(height: 16),
                Expanded(
                  child: _steps.isEmpty
                      ? _buildEmptyState(context)
                      : _buildStepsList(context),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskModal(), // Modo Añadir
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Paso'),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progreso Diario',
                  style: Theme.of(context).textTheme.titleLarge),
              Text('${(_dailyProgress * 100).toInt()}%',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _dailyProgress,
              minHeight: 12,
              color: colorScheme.primary,
              backgroundColor: colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _steps.length,
      itemBuilder: (context, index) {
        final step = _steps[index];
        final isCompleted = step.isCompleted;

        IconData leadingIcon = Icons.check;
        if (step.iconCodePoint != null) {
          leadingIcon =
              IconData(step.iconCodePoint!, fontFamily: 'MaterialIcons');
        }

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          color: isCompleted
              ? Theme.of(context).colorScheme.surfaceContainerLow
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isCompleted
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: ListTile(
            // Tap en la tarjeta AHORA marca COMPLETADO (Toggle)
            onTap: () => _toggleStep(index),
            leading: GestureDetector(
              // Tap en el icono TAMBIÉN marca completado
              onTap: () => _toggleStep(index),
              child: CircleAvatar(
                backgroundColor: isCompleted
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.5),
                child: Icon(
                  leadingIcon,
                  color: isCompleted
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            title: Text(
              step.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.black54 : Colors.black87,
              ),
            ),
            subtitle: Text(
              "${step.date.hour.toString().padLeft(2, '0')}:${step.date.minute.toString().padLeft(2, '0')}",
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded),
                  color: Colors.orange,
                  onPressed: () {
                    TtsService().speak(step.title);
                  },
                ),
                // Botón explícito para EDITAR
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: Colors.grey,
                  onPressed: () {
                    showParentalGate(context, () {
                      _openTaskModal(existingItem: step, index: index);
                    });
                  },
                ),
                if (isCompleted)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.star, color: Colors.orange),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checklist_rtl_rounded,
              size: 100,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
          const SizedBox(height: 24),
          const Text('¡Comienza tu día!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// MODAL DE AÑADIR/EDITAR TAREA
// --------------------------------------------------------------------------
class AddTaskModal extends StatefulWidget {
  final Function(StepItem) onTaskSaved;
  final VoidCallback? onTaskDeleted; // Callback para borrar
  final StepItem? existingItem; // Item para editar (opcional)

  const AddTaskModal({
    super.key,
    required this.onTaskSaved,
    this.onTaskDeleted,
    this.existingItem,
  });

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  final TextEditingController _titleController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  IconData _selectedIcon = Icons.star;

  // Lista de iconos seleccionables
  final List<IconData> _availableIcons = [
    Icons.medication,
    Icons.sports_esports,
    Icons.pets,
    Icons.directions_bike,
    Icons.icecream,
    Icons.menu_book,
    Icons.bed,
    Icons.brush,
    Icons.checkroom,
    Icons.school,
    Icons.wb_sunny,
    Icons.music_note,
    Icons.restaurant,
    Icons.cleaning_services,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingItem != null) {
      // MODO EDICIÓN: Precargamos datos de la tarea existente
      final item = widget.existingItem!;
      _titleController.text = item.title;
      _selectedTime = TimeOfDay(hour: item.date.hour, minute: item.date.minute);
      if (item.iconCodePoint != null) {
        _selectedIcon =
            IconData(item.iconCodePoint!, fontFamily: 'MaterialIcons');
      }
    }
  }

  void _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveTask() {
    if (_titleController.text.isEmpty) return;

    final now = DateTime.now();
    final taskTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Creamos nuevo o preservamos estado de completado si editamos
    final newItem = StepItem(
      title: _titleController.text,
      date: taskTime,
      iconCodePoint: _selectedIcon.codePoint,
      isCompleted: widget.existingItem?.isCompleted ?? false,
    );

    // Programar Notificación
    NotificationService().scheduleDailyNotification(
      newItem.title.hashCode,
      newItem.title,
      _selectedTime,
    );

    widget.onTaskSaved(newItem);
    Navigator.pop(context);
  }

  void _deleteTask() {
    if (widget.onTaskDeleted != null) {
      widget.onTaskDeleted!();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? 'Editar Hábito' : 'Nueva Misión',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 16),
          // Campo de Texto
          TextField(
            controller: _titleController,
            autofocus: !isEditing, // Autoenfoque solo si es nuevo
            decoration: InputDecoration(
              labelText: 'Nombre del hábito',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              prefixIcon: const Icon(Icons.edit),
            ),
          ),
          const SizedBox(height: 16),
          // Selector de Hora
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time),
                  label: Text('Hora: ${_selectedTime.format(context)}'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Selector de Iconos
          Text(
            'Elige un icono:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _availableIcons.length,
              itemBuilder: (context, index) {
                final icon = _availableIcons[index];
                final isSelected = icon == _selectedIcon;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = icon;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 60,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          // Botones de acción
          Row(
            children: [
              if (isEditing)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: IconButton.filledTonal(
                    onPressed: _deleteTask,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _saveTask,
                  icon: const Icon(Icons.check),
                  label: Text(isEditing ? 'Guardar Cambios' : '¡Listo!'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// VISTA DE JUEGOS (Game Zone)
// --------------------------------------------------------------------------
class GamesView extends StatelessWidget {
  const GamesView({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      {
        'title': 'El Arca de Noé',
        'subtitle': 'Memoria',
        'color': const Color(0xFFAED581),
        'icon': Icons.pets,
        'page': const NoahArkGame(),
      },
      {
        'title': 'Túnica de José',
        'subtitle': 'Colores',
        'color': const Color(0xFFFFB74D),
        'icon': Icons.palette,
        'page': const JosephTunicGame(),
      },
      {
        'title': 'David vs Goliat',
        'subtitle': 'Movimiento',
        'color': const Color(0xFFE57373),
        'icon': Icons.fitness_center,
        'page': const GiantsFallGame(),
      },
      {
        'title': 'La Creación',
        'subtitle': 'Trivia',
        'color': const Color(0xFF4FC3F7),
        'icon': Icons.public,
        'page': const CreationQuizGame(),
      },
      {
        'title': 'Jonás y la Ballena',
        'subtitle': 'Laberinto',
        'color': Colors.purpleAccent,
        'icon': Icons.water,
        'page': const JonahGame(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zona de Juegos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columnas
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0, // Tarjetas cuadradas
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => game['page'] as Widget),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: game['color'] as Color,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white30,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(game['icon'] as IconData,
                          size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      game['title'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      game['subtitle'] as String,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
