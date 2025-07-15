import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  // LibreTranslate - Totalmente gratuito, sem chave necessária
  static const String _baseUrl = 'https://libretranslate.com/translate';
  
  /// Traduz texto do português para alemão
  static Future<String?> translateToGerman(String text) async {
    if (text.trim().isEmpty) return null;
    
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
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
        return data['translatedText'] as String;
      } else {
        print('Erro na tradução: ${response.statusCode} - ${response.body}');
        // Fallback para modo de teste se a API falhar
        return _getTestTranslation(text, 'pt', 'de');
      }
    } catch (e) {
      print('Erro ao traduzir: $e');
      // Fallback para modo de teste se a API falhar
      return _getTestTranslation(text, 'pt', 'de');
    }
  }
  
  /// Traduz texto do alemão para português
  static Future<String?> translateToPortuguese(String text) async {
    if (text.trim().isEmpty) return null;
    
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
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
        return data['translatedText'] as String;
      } else {
        print('Erro na tradução: ${response.statusCode} - ${response.body}');
        // Fallback para modo de teste se a API falhar
        return _getTestTranslation(text, 'de', 'pt');
      }
    } catch (e) {
      print('Erro ao traduzir: $e');
      // Fallback para modo de teste se a API falhar
      return _getTestTranslation(text, 'de', 'pt');
    }
  }
  
  /// Traduções de teste como fallback
  static String? _getTestTranslation(String text, String from, String to) {
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
      
      return translations[lowerText] ?? 'Tradução não disponível';
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
      
      return translations[lowerText] ?? 'Tradução não disponível';
    }
    
    return 'Tradução não disponível';
  }
} 