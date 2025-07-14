import 'package:flutter/material.dart';
import '../models/word.dart';

class WordTile extends StatefulWidget {
  final Word word;
  final VoidCallback? onDelete;

  const WordTile({super.key, required this.word, this.onDelete});

  @override
  State<WordTile> createState() => _WordTileState();
}

class _WordTileState extends State<WordTile> {
  bool _expanded = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.12 : 0.08),
              blurRadius: _isHovered ? 20 : 12,
              offset: Offset(0, _isHovered ? 8 : 4),
              spreadRadius: _isHovered ? 2 : 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.word.german,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.black87,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.expand_more_rounded,
                          color: Colors.grey[600],
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  if (_expanded) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.word.portuguese,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    if (widget.word.example != null && widget.word.example!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Text(
                            widget.word.example!,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    if (widget.onDelete != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: IconButton(
                            icon: Icon(Icons.delete_outline_rounded, color: Colors.red[400]),
                            onPressed: widget.onDelete,
                            tooltip: 'Deletar palavra',
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 