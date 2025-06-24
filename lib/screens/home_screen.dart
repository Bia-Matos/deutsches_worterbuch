import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/word.dart';
import '../widgets/word_tile.dart';
import '../widgets/search_bar.dart';
import '../widgets/custom_title.dart';
import 'add_word_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<Word>> _groupByLetter(List<Word> words) {
    final Map<String, List<Word>> grouped = {};
    for (var word in words) {
      final letter = word.german.isNotEmpty ? word.german[0].toUpperCase() : '#';
      grouped.putIfAbsent(letter, () => []).add(word);
    }
    final sorted = Map.fromEntries(grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
    return sorted;
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
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Column(
          children: [
            // Cabeçalho personalizado
            const CustomTitle(),
            // Conteúdo principal
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SearchBarWidget(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _search = value.trim()),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: StreamBuilder<List<Word>>(
                        stream: FirestoreService().getWords(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final words = snapshot.data ?? [];
                          final filtered = words.where((w) =>
                            w.german.toLowerCase().contains(_search.toLowerCase()) ||
                            w.portuguese.toLowerCase().contains(_search.toLowerCase())
                          ).toList();
                          if (filtered.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.book_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Nenhuma palavra cadastrada ainda.',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          final grouped = _groupByLetter(filtered);
                          return ListView(
                            children: grouped.entries.map((entry) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  ...entry.value.map((word) => WordTile(
                                        word: word,
                                        onDelete: () async {
                                          await FirestoreService().deleteWord(word.id);
                                        },
                                      )),
                                ],
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddWordScreen()),
          );
        },
        backgroundColor: Colors.red[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
} 