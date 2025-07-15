import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  // Inicializa o TTS com configurações alemãs
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configura idioma alemão
      await _flutterTts.setLanguage("de-DE");
      
      // Configura velocidade de fala
      await _flutterTts.setSpeechRate(0.4); // Velocidade moderada
      
      // Configura volume
      await _flutterTts.setVolume(1.0);
      
      // Configura pitch (tom da voz)
      await _flutterTts.setPitch(1.0);
      
      _isInitialized = true;
      print('🎵 AudioService inicializado com sucesso');
    } catch (e) {
      print('❌ Erro ao inicializar AudioService: $e');
    }
  }

  // Reproduz a pronúncia de uma palavra alemã
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      print('🔊 Reproduzindo: $text');
      await _flutterTts.speak(text);
    } catch (e) {
      print('❌ Erro ao reproduzir áudio: $e');
    }
  }

  // Para a reprodução atual
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('❌ Erro ao parar áudio: $e');
    }
  }

  // Verifica se está reproduzindo
  Future<bool> isSpeaking() async {
    try {
      // Como isSpeaking() não está disponível, retornamos false
      // Em uma implementação futura, podemos usar um estado interno
      return false;
    } catch (e) {
      print('❌ Erro ao verificar status: $e');
      return false;
    }
  }

  // Configura velocidade de fala
  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate);
    } catch (e) {
      print('❌ Erro ao configurar velocidade: $e');
    }
  }

  // Configura volume
  Future<void> setVolume(double volume) async {
    try {
      await _flutterTts.setVolume(volume);
    } catch (e) {
      print('❌ Erro ao configurar volume: $e');
    }
  }

  // Obtém vozes disponíveis
  Future<List<Map<String, dynamic>>> getVoices() async {
    try {
      // Como getVoices pode não estar disponível, retornamos lista vazia
      // Em uma implementação futura, podemos usar uma lista hardcoded
      return [];
    } catch (e) {
      print('❌ Erro ao obter vozes: $e');
      return [];
    }
  }

  // Limpa recursos
  void dispose() {
    stop();
  }
} 