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
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: Colors.amber[50],
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.amber.withOpacity(0.15),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.menu_book_rounded,
                                      size: 54,
                                      color: Colors.amber[800],
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    'Noch keine Wörter gefunden!',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Füge das erste Wort hinzu und beginne dein Wörterbuch!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[700],
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Wort hinzufügen'),
                                    onPressed: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const AddWordScreen()),
                                      );
                                    },
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