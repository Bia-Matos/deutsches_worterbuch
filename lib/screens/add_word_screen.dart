import 'package:flutter/material.dart';
import '../models/word.dart';
import '../services/firestore_service.dart';

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
  bool _isLoading = false;

  @override
  void dispose() {
    _germanController.dispose();
    _portugueseController.dispose();
    _exampleController.dispose();
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
    );
    await FirestoreService().addWord(word);
    setState(() => _isLoading = false);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Palavra'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _germanController,
                decoration: const InputDecoration(
                  labelText: 'Palavra em Alemão',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _portugueseController,
                decoration: const InputDecoration(
                  labelText: 'Tradução em Português',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _exampleController,
                decoration: const InputDecoration(
                  labelText: 'Exemplo de frase (opcional)',
                  border: OutlineInputBorder(),
                ),
                minLines: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: _isLoading ? null : _saveWord,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 