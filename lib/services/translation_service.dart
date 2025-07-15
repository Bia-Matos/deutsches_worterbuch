import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  // MyMemory API - Totalmente gratuito, sem chave necessária
  static const String _baseUrl = 'https://api.mymemory.translated.net/get';
  
  /// Traduz texto do português para alemão
  static Future<String?> translateToGerman(String text) async {
    if (text.trim().isEmpty) return null;
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?q=${Uri.encodeComponent(text)}&langpair=pt|de'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translatedText = data['responseData']['translatedText'] as String;
        
        if (translatedText.isNotEmpty && translatedText != text) {
          return translatedText;
        } else {
          // Se a tradução falhou, usa fallback
          return _getTestTranslation(text, 'pt', 'de');
        }
      } else {
        print('Erro na tradução: ${response.statusCode} - ${response.body}');
        return _getTestTranslation(text, 'pt', 'de');
      }
    } catch (e) {
      print('Erro ao traduzir: $e');
      return _getTestTranslation(text, 'pt', 'de');
    }
  }
  
  /// Traduz texto do alemão para português
  static Future<String?> translateToPortuguese(String text) async {
    if (text.trim().isEmpty) return null;
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?q=${Uri.encodeComponent(text)}&langpair=de|pt'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translatedText = data['responseData']['translatedText'] as String;
        
        if (translatedText.isNotEmpty && translatedText != text) {
          return translatedText;
        } else {
          // Se a tradução falhou, usa fallback
          return _getTestTranslation(text, 'de', 'pt');
        }
      } else {
        print('Erro na tradução: ${response.statusCode} - ${response.body}');
        return _getTestTranslation(text, 'de', 'pt');
      }
    } catch (e) {
      print('Erro ao traduzir: $e');
      return _getTestTranslation(text, 'de', 'pt');
    }
  }
  
  /// Traduções de teste como fallback
  static String? _getTestTranslation(String text, String from, String to) {
    final lowerText = text.toLowerCase();
    
    // Traduções de teste português → alemão
    if (from == 'pt' && to == 'de') {
      final translations = {
        'oi': 'Hallo',
        'olá': 'Hallo',
        'bom dia': 'Guten Morgen',
        'boa tarde': 'Guten Tag',
        'boa noite': 'Gute Nacht',
        'obrigado': 'Danke',
        'obrigada': 'Danke',
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
        'tchau': 'Tschüss',
        'adeus': 'Auf Wiedersehen',
        'bem-vindo': 'Willkommen',
        'feliz aniversário': 'Alles Gute zum Geburtstag',
        'parabéns': 'Herzlichen Glückwunsch',
        'desculpe': 'Entschuldigung',
        'com licença': 'Entschuldigung',
        'você fala alemão?': 'Sprichst du Deutsch?',
        'eu não entendo': 'Ich verstehe nicht',
        'pode repetir?': 'Kannst du das wiederholen?',
        'mais devagar': 'Langsamer',
        'obrigado pela ajuda': 'Danke für die Hilfe',
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
        'tschüss': 'Tchau',
        'auf wiedersehen': 'Adeus',
        'willkommen': 'Bem-vindo',
        'alles gute zum geburtstag': 'Feliz aniversário',
        'herzlichen glückwunsch': 'Parabéns',
        'entschuldigung': 'Desculpe',
        'sprichst du deutsch?': 'Você fala alemão?',
        'ich verstehe nicht': 'Eu não entendo',
        'kannst du das wiederholen?': 'Pode repetir?',
        'langsamer': 'Mais devagar',
        'danke für die hilfe': 'Obrigado pela ajuda',
      };
      
      return translations[lowerText] ?? 'Tradução não disponível';
    }
    
    return 'Tradução não disponível';
  }
} 