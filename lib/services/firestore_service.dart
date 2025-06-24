import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/word.dart';

class FirestoreService {
  final CollectionReference wordsCollection =
      FirebaseFirestore.instance.collection('words');

  Future<void> addWord(Word word) async {
    await wordsCollection.add(word.toMap());
  }

  Stream<List<Word>> getWords() {
    return wordsCollection
        .orderBy('german')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Word.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> deleteWord(String id) async {
    await wordsCollection.doc(id).delete();
  }
} 