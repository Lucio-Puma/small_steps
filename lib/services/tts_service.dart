import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  late FlutterTts _flutterTts;

  factory TtsService() {
    return _instance;
  }

  TtsService._internal() {
    _flutterTts = FlutterTts();
    _init();
  }

  void _init() async {
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setSpeechRate(0.5); // Velocidad lenta para niños
    await _flutterTts.setPitch(1.0);

    // Opcional: Manejo de errores o estado
    _flutterTts.setStartHandler(() {
      print("Playing");
    });

    _flutterTts.setCompletionHandler(() {
      print("Complete");
    });

    _flutterTts.setErrorHandler((msg) {
      print("error: $msg");
    });
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
