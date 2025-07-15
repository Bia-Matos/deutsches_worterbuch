import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class TranslationService {
  static const String _baseUrl = 'https://translation.googleapis.com/language/translate/v2';
  
  /// Traduz texto do português para alemão
  static Future<String?> translateToGerman(String text) async {
    if (text.trim().isEmpty) return null;
    
    // Modo de teste para desenvolvimento
    if (ApiConfig.useTestMode) {
      return _getTestTranslation(text, 'pt', 'de');
    }
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=${ApiConfig.googleTranslateApiKey}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'q': text,
          'source': 'pt',
          'target': 'de',
          'format': 'text'
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translations = data['data']['translations'] as List;
        
        if (translations.isNotEmpty) {
          return translations.first['translatedText'] as String;
        }
      } else {
        print('Erro na tradução: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erro ao traduzir: $e');
    }
    
    return null;
  }
  
  /// Traduz texto do alemão para português
  static Future<String?> translateToPortuguese(String text) async {
    if (text.trim().isEmpty) return null;
    
    // Modo de teste para desenvolvimento
    if (ApiConfig.useTestMode) {
      return _getTestTranslation(text, 'de', 'pt');
    }
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=${ApiConfig.googleTranslateApiKey}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'q': text,
          'source': 'de',
          'target': 'pt',
          'format': 'text'
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translations = data['data']['translations'] as List;
        
        if (translations.isNotEmpty) {
          return translations.first['translatedText'] as String;
        }
      } else {
        print('Erro na tradução: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erro ao traduzir: $e');
    }
    
    return null;
  }
  
  /// Traduções de teste para desenvolvimento
  static String? _getTestTranslation(String text, String from, String to) {
    // Simula um delay de rede
    Future.delayed(const Duration(milliseconds: 500));
    
    final lowerText = text.toLowerCase();
    
    // Traduções de teste português → alemão
    if (from == 'pt' && to == 'de') {
      final translations = {
        'olá': 'Hallo',
        'bom dia': 'Guten Morgen',
        'boa tarde': 'Guten Tag',
        'boa noite': 'Gute Nacht',
        'obrigado': 'Danke',
        'por favor': 'Bitte',
        'sim': 'Ja',
        'não': 'Nein',
        'água': 'Wasser',
        'pão': 'Brot',
        'casa': 'Haus',
        'carro': 'Auto',
        'livro': 'Buch',
        'cachorro': 'Hund',
        'gato': 'Katze',
        'eu amo você': 'Ich liebe dich',
        'como você está?': 'Wie geht es dir?',
        'eu estou bem': 'Mir geht es gut',
        'qual é o seu nome?': 'Wie heißt du?',
        'meu nome é': 'Mein Name ist',
      };
      
      return translations[lowerText] ?? 'Tradução não disponível em modo de teste';
    }
    
    // Traduções de teste alemão → português
    if (from == 'de' && to == 'pt') {
      final translations = {
        'hallo': 'Olá',
        'guten morgen': 'Bom dia',
        'guten tag': 'Boa tarde',
        'gute nacht': 'Boa noite',
        'danke': 'Obrigado',
        'bitte': 'Por favor',
        'ja': 'Sim',
        'nein': 'Não',
        'wasser': 'Água',
        'brot': 'Pão',
        'haus': 'Casa',
        'auto': 'Carro',
        'buch': 'Livro',
        'hund': 'Cachorro',
        'katze': 'Gato',
        'ich liebe dich': 'Eu amo você',
        'wie geht es dir?': 'Como você está?',
        'mir geht es gut': 'Eu estou bem',
        'wie heißt du?': 'Qual é o seu nome?',
        'mein name ist': 'Meu nome é',
      };
      
      return translations[lowerText] ?? 'Tradução não disponível em modo de teste';
    }
    
    return 'Tradução não disponível em modo de teste';
  }
} 