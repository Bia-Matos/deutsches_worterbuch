import 'package:flutter/material.dart';
import '../models/word.dart';

class WordTile extends StatelessWidget {
  final Word word;
  final VoidCallback? onDelete;

  const WordTile({super.key, required this.word, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
          border: Border.all(
            color: Color(0xFFFFD700).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            word.german,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                word.portuguese,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              if (word.example != null && word.example!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Text(
                      'Exemplo: ${word.example}',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.blue[800],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          trailing: onDelete != null
              ? IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                  onPressed: onDelete,
                )
              : null,
        ),
      ),
    );
  }
} 