import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../models/word.dart';
import '../widgets/word_tile.dart';
import '../widgets/custom_title.dart';
import 'add_word_screen.dart';
import '../services/activity_service.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _search = '';
  
  // Cache e otimizações
  List<Word> _allWords = [];
  List<Word> _filteredWords = [];
  bool _isLoading = true;
  Timer? _debounceTimer;
  
  // Stream subscription para gerenciar recursos
  StreamSubscription<List<Word>>? _wordsSubscription;

  @override
  void initState() {
    super.initState();
    _loadWords();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _wordsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadWords() async {
    try {
      // Primeiro carrega do cache
      final cachedWords = await FirestoreService().getWordsFromCache();
      if (mounted) {
        setState(() {
          _allWords = cachedWords;
          _filteredWords = cachedWords;
          _isLoading = false;
        });
      }
      
      // Depois escuta mudanças em tempo real
      _wordsSubscription = FirestoreService().getWords().listen((words) {
        if (mounted) {
          setState(() {
            _allWords = words;
            _filterWords();
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    
    // Debounce para evitar muitas operações de filtro
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted && _search != query) {
        setState(() {
          _search = query;
          _filterWords();
        });
      }
    });
  }

  void _filterWords() {
    if (_search.isEmpty) {
      _filteredWords = _allWords;
    } else {
      final lowercaseSearch = _search.toLowerCase();
      _filteredWords = _allWords.where((word) =>
        word.german.toLowerCase().contains(lowercaseSearch) ||
        word.portuguese.toLowerCase().contains(lowercaseSearch)
      ).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            const CustomTitle(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _allWords.isEmpty
                      ? _EmptyState()
                      : _WordsList(
                          words: _filteredWords,
                          allWords: _allWords,
                          searchController: _searchController,
                          onDeleteWord: _deleteWord,
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteWord(String wordId) async {
    await FirestoreService().deleteWord(wordId);
  }
}

// Widget separado para a lista de palavras (evita rebuild desnecessário)
class _WordsList extends StatelessWidget {
  final List<Word> words;
  final List<Word> allWords;
  final TextEditingController searchController;
  final Function(String) onDeleteWord;

  const _WordsList({
    required this.words,
    required this.allWords,
    required this.searchController,
    required this.onDeleteWord,
  });

  @override
  Widget build(BuildContext context) {
    final nouns = allWords.where((w) => w.isNoun).length;
    
    return Column(
      children: [
        // Hero Section com estatísticas (memoizado)
        _HeroSection(
          totalWords: allWords.length,
          nouns: nouns,
          searchController: searchController,
        ),
        
        // Lista de palavras
        Expanded(
          child: words.isEmpty 
              ? _EmptySearchState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: words.length,
                  // Otimização: usar itemExtent para melhor performance
                  itemExtent: null, // Deixa o Flutter calcular automaticamente
                  itemBuilder: (context, index) {
                    return WordTile(
                      key: ValueKey(words[index].id), // Key para evitar rebuilds
                      word: words[index],
                      onDelete: () => onDeleteWord(words[index].id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// Widget separado para hero section (evita rebuild desnecessário)
class _HeroSection extends StatelessWidget {
  final int totalWords;
  final int nouns;
  final TextEditingController searchController;

  const _HeroSection({
    required this.totalWords,
    required this.nouns,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Seu Progresso',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Estatísticas
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Palavras',
                  value: totalWords.toString(),
                  icon: Icons.book_rounded,
                  color: Colors.blue[600]!,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Substantivos',
                  value: nouns.toString(),
                  icon: Icons.category_rounded,
                  color: Colors.green[600]!,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StreamBuilder<int>(
                  stream: ActivityService().getActiveDaysStream(),
                  builder: (context, snapshot) {
                    return _StatCard(
                      title: 'Dias Ativo',
                      value: (snapshot.data ?? 0).toString(),
                      icon: Icons.calendar_today_rounded,
                      color: Colors.orange[600]!,
                    );
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Barra de busca otimizada
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar palavras...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: GoogleFonts.lato(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue[400]!,
                      Colors.blue[500]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddWordScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  iconSize: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget para cards de estatísticas
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Widget para estado vazio da busca
class _EmptySearchState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma palavra encontrada',
            style: GoogleFonts.lato(
              color: Colors.grey[500],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente buscar por outros termos',
            style: GoogleFonts.lato(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para estado vazio (sem palavras)
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              size: 80,
              color: Colors.blue[300],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Comece sua jornada!',
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione suas primeiras palavras em alemão\ne comece a expandir seu vocabulário',
            style: GoogleFonts.lato(
              fontSize: 16,
              color: Colors.grey[500],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue[400]!,
                  Colors.blue[500]!,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddWordScreen()),
                );
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(
                'Adicionar primeira palavra',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 