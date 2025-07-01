import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/word.dart';
import '../widgets/custom_title.dart';
import 'package:google_fonts/google_fonts.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showBack = false;
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    setState(() {
      _showBack = !_showBack;
      if (_showBack) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomTitle(),
          Expanded(
            child: StreamBuilder<List<Word>>(
              stream: FirestoreService().getWords(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final words = snapshot.data ?? [];
                if (words.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma palavra cadastrada.'),
                  );
                }
                final word = words[_currentIndex];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _flipCard,
                        child: AnimatedBuilder(
                          animation: _flipAnimation,
                          builder: (context, child) {
                            final isFront = _flipAnimation.value < 0.5;
                            final angle = _flipAnimation.value * 3.1416;
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(angle),
                              child: isFront
                                  ? _FlashcardFront(word: word)
                                  : Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()..rotateY(3.1416),
                                      child: _FlashcardBack(word: word),
                                    ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          color: Colors.black,
                          onPressed: _currentIndex > 0
                              ? () => setState(() {
                                    _currentIndex--;
                                    _showBack = false;
                                    _controller.reverse();
                                  })
                              : null,
                        ),
                        const SizedBox(width: 48),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios_rounded),
                          color: Colors.red,
                          onPressed: _currentIndex < words.length - 1
                              ? () => setState(() {
                                    _currentIndex++;
                                    _showBack = false;
                                    _controller.reverse();
                                  })
                              : null,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FlashcardFront extends StatelessWidget {
  final Word word;
  const _FlashcardFront({required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (word.imageUrl != null && word.imageUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 18.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  word.imageUrl!,
                  width: 180,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 60, color: Colors.grey[400]),
                ),
              ),
            ),
          Text(
            word.german,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FlashcardBack extends StatelessWidget {
  final Word word;
  const _FlashcardBack({required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          word.portuguese,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
} 