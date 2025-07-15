import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/word.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final CollectionReference wordsCollection =
      FirebaseFirestore.instance.collection('words');

  // Cache local para evitar queries desnecessárias
  List<Word>? _cachedWords;
  DateTime? _lastCacheUpdate;
  static const Duration _cacheExpiration = Duration(minutes: 5);

  // Stream controller para gerenciar updates
  Stream<List<Word>>? _wordsStream;

  Future<void> addWord(Word word) async {
    await wordsCollection.add(word.toMap());
    _invalidateCache();
  }

  Future<void> deleteWord(String id) async {
    await wordsCollection.doc(id).delete();
    _invalidateCache();
  }

  // Método otimizado para buscar palavras
  Stream<List<Word>> getWords() {
    // Reutiliza o stream existente se já estiver ativo
    _wordsStream ??= wordsCollection
        .orderBy('german')
        .snapshots()
        .map((snapshot) {
          final words = snapshot.docs
              .map((doc) => Word.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();
          
          // Atualiza cache local
          _cachedWords = words;
          _lastCacheUpdate = DateTime.now();
          
          return words;
        });
    
    return _wordsStream!;
  }

  // Método para buscar palavras do cache quando possível
  Future<List<Word>> getWordsFromCache() async {
    if (_cachedWords != null && 
        _lastCacheUpdate != null && 
        DateTime.now().difference(_lastCacheUpdate!) < _cacheExpiration) {
      return _cachedWords!;
    }
    
    // Se não tem cache válido, busca do Firestore
    final snapshot = await wordsCollection.orderBy('german').get();
    final words = snapshot.docs
        .map((doc) => Word.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    
    _cachedWords = words;
    _lastCacheUpdate = DateTime.now();
    
    return words;
  }

  // Busca paginada para listas grandes
  Future<List<Word>> getWordsPaginated({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = wordsCollection.orderBy('german').limit(limit);
    
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Word.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Busca por texto otimizada
  Future<List<Word>> searchWords(String searchTerm) async {
    if (searchTerm.isEmpty) return await getWordsFromCache();
    
    final words = await getWordsFromCache();
    final lowercaseSearch = searchTerm.toLowerCase();
    
    return words.where((word) =>
      word.german.toLowerCase().contains(lowercaseSearch) ||
      word.portuguese.toLowerCase().contains(lowercaseSearch)
    ).toList();
  }

  void _invalidateCache() {
    _cachedWords = null;
    _lastCacheUpdate = null;
  }

  // Método para pre-carregar dados
  Future<void> preloadData() async {
    await getWordsFromCache();
  }

  // Limpa recursos
  void dispose() {
    _wordsStream = null;
    _invalidateCache();
  }
} 