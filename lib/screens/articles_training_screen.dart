import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../models/word.dart';
import '../widgets/custom_title.dart';
import '../widgets/audio_button.dart';
import '../services/activity_service.dart';

class ArticlesTrainingScreen extends StatefulWidget {
  const ArticlesTrainingScreen({super.key});

  @override
  State<ArticlesTrainingScreen> createState() => _ArticlesTrainingScreenState();
}

class _ArticlesTrainingScreenState extends State<ArticlesTrainingScreen> {
  int _currentIndex = 0;
  String? _selectedArticle;
  bool _showResult = false;
  bool _isCorrect = false;
  int _correctAnswers = 0;
  int _totalAnswers = 0;
  bool _isLoading = true;
  List<Word> _nounWords = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadWords();
    ActivityService().recordArticleTrainingActivity();
  }

  Future<void> _loadWords() async {
    try {
      print('🔍 Carregando palavras...');
      
      // Primeiro tenta carregar do cache
      List<Word> words = await FirestoreService().getWordsFromCache();
      print('📦 Palavras do cache: ${words.length}');
      
      // Se não tiver no cache, busca do Firestore com timeout
      if (words.isEmpty) {
        print('🌐 Buscando do Firestore...');
        words = await FirestoreService().getWords().first.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('⏰ Timeout ao buscar palavras');
            return <Word>[];
          },
        );
      }
      
      final nouns = words.where((word) => word.isNoun).toList();
      
      print('📚 Total de palavras: ${words.length}');
      print('🏷️ Substantivos encontrados: ${nouns.length}');
      
      // Debug: mostra alguns substantivos se existirem
      if (nouns.isNotEmpty) {
        print('🎯 Primeiros substantivos:');
        for (int i = 0; i < (nouns.length > 3 ? 3 : nouns.length); i++) {
          print('   ${nouns[i].article} ${nouns[i].german}');
        }
      }
      
      if (mounted) {
        setState(() {
          _nounWords = nouns;
          _isLoading = false;
        });
        print('✅ Estado atualizado com sucesso');
      }
    } catch (e) {
      print('❌ Erro ao carregar palavras: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar palavras: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomTitle(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando palavras...'),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Erro!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = '';
                  _isLoading = true;
                });
                _loadWords();
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_nounWords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhum substantivo encontrado',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione palavras com artigos para começar o treino!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return _buildTrainingContent();
  }

  Widget _buildTrainingContent() {
    final currentWord = _nounWords[_currentIndex];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Header com estatísticas
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Acertos',
                  value: '$_correctAnswers',
                  color: Colors.green,
                ),
                _StatItem(
                  label: 'Total',
                  value: '$_totalAnswers',
                  color: Colors.blue,
                ),
                _StatItem(
                  label: 'Taxa',
                  value: _totalAnswers > 0 
                      ? '${((_correctAnswers / _totalAnswers) * 100).round()}%'
                      : '0%',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Card principal
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Qual é o artigo correto?',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Palavra
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentWord.german,
                        style: GoogleFonts.lato(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(width: 12),
                      AudioButton(
                        text: currentWord.german,
                        size: 32,
                        color: Colors.blue[600],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Botões de artigos
                  if (!_showResult) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ArticleButton(
                          article: 'der',
                          isSelected: _selectedArticle == 'der',
                          onTap: () => setState(() => _selectedArticle = 'der'),
                        ),
                        _ArticleButton(
                          article: 'die',
                          isSelected: _selectedArticle == 'die',
                          onTap: () => setState(() => _selectedArticle = 'die'),
                        ),
                        _ArticleButton(
                          article: 'das',
                          isSelected: _selectedArticle == 'das',
                          onTap: () => setState(() => _selectedArticle = 'das'),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: const Color(0xFFFFD700),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _selectedArticle != null ? _checkAnswer : null,
                      child: Text(
                        'Verificar',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Resultado
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _isCorrect ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isCorrect ? Colors.green[200]! : Colors.red[200]!,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _isCorrect ? Icons.check_circle : Icons.cancel,
                            color: _isCorrect ? Colors.green : Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isCorrect ? 'Correto!' : 'Incorreto!',
                            style: GoogleFonts.lato(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _isCorrect ? Colors.green[700] : Colors.red[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${currentWord.article} ${currentWord.german}',
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: const Color(0xFFFFD700),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _nextWord,
                      child: Text(
                        'Próxima',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkAnswer() {
    final currentWord = _nounWords[_currentIndex];
    setState(() {
      _showResult = true;
      _isCorrect = _selectedArticle == currentWord.article;
      _totalAnswers++;
      if (_isCorrect) _correctAnswers++;
    });
    
    ActivityService().recordArticleTrainingActivity();
  }

  void _nextWord() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _nounWords.length;
      _selectedArticle = null;
      _showResult = false;
    });
    
    ActivityService().recordArticleTrainingActivity();
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ArticleButton extends StatelessWidget {
  final String article;
  final bool isSelected;
  final VoidCallback onTap;

  const _ArticleButton({
    required this.article,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.1 : 0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            article,
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFFFFD700) : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
} 