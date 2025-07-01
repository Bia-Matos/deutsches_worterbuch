import 'package:flutter/material.dart';
import '../models/word.dart';
import '../services/firestore_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class AddWordScreen extends StatefulWidget {
  const AddWordScreen({super.key});

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _germanController = TextEditingController();
  final _portugueseController = TextEditingController();
  final _exampleController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String? _uploadedImageUrl;
  bool _uploadingImage = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _germanController.dispose();
    _portugueseController.dispose();
    _exampleController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveWord() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final word = Word(
      id: '',
      german: _germanController.text.trim(),
      portuguese: _portugueseController.text.trim(),
      example: _exampleController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
    );
    await FirestoreService().addWord(word);
    setState(() => _isLoading = false);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickAndUploadImage() async {
    setState(() => _uploadingImage = true);
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      final fileBytes = result.files.single.bytes!;
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('word_images/$fileName');
      final uploadTask = await ref.putData(fileBytes);
      final url = await uploadTask.ref.getDownloadURL();
      setState(() {
        _uploadedImageUrl = url;
        _imageUrlController.text = url;
      });
    }
    setState(() => _uploadingImage = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 32),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.menu_book_rounded, color: Colors.red[700], size: 32),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              'Neues Wort hinzufügen',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Fülle die Felder aus, um ein neues Wort zu speichern.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _germanController,
                        decoration: InputDecoration(
                          labelText: 'Deutsch',
                          hintText: 'z.B. Apfel',
                          prefixIcon: Icon(Icons.language, color: Colors.red[700]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Pflichtfeld' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _portugueseController,
                        decoration: InputDecoration(
                          labelText: 'Portugiesisch',
                          hintText: 'z.B. Maçã',
                          prefixIcon: Icon(Icons.translate, color: Colors.amber[800]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Pflichtfeld' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _exampleController,
                        decoration: InputDecoration(
                          labelText: 'Beispielsatz (optional)',
                          hintText: 'z.B. Der Apfel ist rot.',
                          prefixIcon: Icon(Icons.chat_bubble_outline, color: Colors.blue[700]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        minLines: 1,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _imageUrlController,
                              decoration: InputDecoration(
                                labelText: 'Bild-URL (optional)',
                                hintText: 'https://...',
                                prefixIcon: Icon(Icons.image, color: Colors.amber[800]),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              keyboardType: TextInputType.url,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: const Color(0xFFFFD700),
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _uploadingImage ? null : _pickAndUploadImage,
                            icon: _uploadingImage
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.upload),
                            label: const Text('Selecionar'),
                          ),
                        ],
                      ),
                      if (_uploadedImageUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _uploadedImageUrl!,
                              height: 120,
                              width: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isLoading ? null : _saveWord,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.check),
                              label: const Text('Speichern'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey[600],
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                textStyle: const TextStyle(fontWeight: FontWeight.w500),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                              child: const Text('Abbrechen'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 