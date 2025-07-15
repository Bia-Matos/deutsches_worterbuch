import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/word.dart';
import '../widgets/custom_title.dart';
import '../widgets/audio_button.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/activity_service.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showBack = false;
  late AnimationController _flipController;
  final ActivityService _activityService = ActivityService();
  
  // Cache local para palavras
  List<Word> _words = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Controlador para flip do card
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _loadWords();
    _activityService.recordFlashcardActivity();
  }

  Future<void> _loadWords() async {
    try {
      final words = await FirestoreService().getWordsFromCache();
      if (mounted) {
        setState(() {
          _words = words;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    setState(() {
      _showBack = !_showBack;
      if (_showBack) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    });
  }

  void _nextCard() {
    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex++;
        _showBack = false;
      });
      _flipController.reset();
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showBack = false;
      });
      _flipController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          const CustomTitle(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _words.isEmpty
                    ? _EmptyState()
                    : _FlashcardContent(
                        word: _words[_currentIndex],
                        currentIndex: _currentIndex,
                        totalWords: _words.length,
                        showBack: _showBack,
                        flipController: _flipController,
                        onFlip: _flipCard,
                        onNext: _nextCard,
                        onPrevious: _previousCard,
                      ),
          ),
        ],
      ),
    );
  }
}

// Widget principal do conteúdo dos flashcards
class _FlashcardContent extends StatelessWidget {
  final Word word;
  final int currentIndex;
  final int totalWords;
  final bool showBack;
  final AnimationController flipController;
  final VoidCallback onFlip;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const _FlashcardContent({
    required this.word,
    required this.currentIndex,
    required this.totalWords,
    required this.showBack,
    required this.flipController,
    required this.onFlip,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Indicador de progresso moderno
          _ProgressIndicator(
            currentIndex: currentIndex,
            totalWords: totalWords,
          ),
          
          const SizedBox(height: 40),
          
          // Flashcard principal
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: onFlip,
                child: AnimatedBuilder(
                  animation: flipController,
                  builder: (context, child) {
                    final isFront = flipController.value < 0.5;
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isFront
                          ? _FlashcardFront(
                              key: const ValueKey('front'),
                              word: word,
                            )
                          : _FlashcardBack(
                              key: const ValueKey('back'),
                              word: word,
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Botões de navegação
          _NavigationButtons(
            onPrevious: onPrevious,
            onNext: onNext,
            currentIndex: currentIndex,
            totalWords: totalWords,
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Indicador de progresso moderno
class _ProgressIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalWords;

  const _ProgressIndicator({
    required this.currentIndex,
    required this.totalWords,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentIndex + 1) / totalWords;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Flashcards',
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Text(
              '${currentIndex + 1} / $totalWords',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue[600],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Barra de progresso
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[400]!, Colors.blue[600]!],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Botões de navegação
class _NavigationButtons extends StatelessWidget {
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final int currentIndex;
  final int totalWords;

  const _NavigationButtons({
    required this.onPrevious,
    required this.onNext,
    required this.currentIndex,
    required this.totalWords,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Botão anterior
        _NavigationButton(
          icon: Icons.arrow_back_ios_rounded,
          label: 'Anterior',
          onTap: currentIndex > 0 ? onPrevious : null,
          isEnabled: currentIndex > 0,
        ),
        
        // Contador
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${currentIndex + 1} / $totalWords',
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        
        // Botão próximo
        _NavigationButton(
          icon: Icons.arrow_forward_ios_rounded,
          label: 'Próximo',
          onTap: currentIndex < totalWords - 1 ? onNext : null,
          isEnabled: currentIndex < totalWords - 1,
        ),
      ],
    );
  }
}

// Widget para botão de navegação individual
class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isEnabled;

  const _NavigationButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isEnabled 
              ? LinearGradient(
                  colors: [Colors.blue[400]!, Colors.blue[600]!],
                )
              : null,
          color: isEnabled ? null : Colors.grey[300],
          borderRadius: BorderRadius.circular(25),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isEnabled ? Colors.white : Colors.grey[500],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isEnabled ? Colors.white : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para estado vazio
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[50]!, Colors.blue[100]!],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.style_outlined,
              size: 80,
              color: Colors.blue[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum flashcard disponível',
            style: GoogleFonts.lato(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione palavras para começar a estudar',
            style: GoogleFonts.lato(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

// Flashcard frontal redesenhado - agora mostra português primeiro
class _FlashcardFront extends StatelessWidget {
  final Word word;
  
  const _FlashcardFront({
    super.key,
    required this.word,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decoração de fundo
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // Conteúdo principal
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Imagem (se disponível)
                if (word.imageUrl != null && word.imageUrl!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        word.imageUrl!,
                        width: 180,
                        height: 120,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 180,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 180,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // Palavra portuguesa (agora na frente)
                Text(
                  word.portuguese,
                  style: GoogleFonts.lato(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                // Indicador para virar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app_rounded, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Toque para ver em alemão',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Flashcard traseiro redesenhado - agora mostra alemão
class _FlashcardBack extends StatelessWidget {
  final Word word;
  
  const _FlashcardBack({
    super.key,
    required this.word,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[400]!,
            Colors.blue[600]!,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decoração de fundo
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // Conteúdo principal
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone alemão
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.language_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Palavra alemã
                Text(
                  word.german,
                  style: GoogleFonts.lato(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                // Botão de áudio para pronúncia
                const SizedBox(height: 16),
                AudioButton(
                  text: word.german,
                  size: 28,
                  color: Colors.white,
                  showLabel: true,
                ),
                
                // Artigo (se disponível)
                if (word.article != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      word.article!,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
                
                // Exemplo (se disponível)
                if (word.example != null && word.example!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      word.example!,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Indicador para virar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app_rounded, size: 16, color: Colors.white.withOpacity(0.8)),
                      const SizedBox(width: 6),
                      Text(
                        'Toque para voltar',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 