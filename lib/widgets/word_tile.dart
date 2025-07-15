import 'package:flutter/material.dart';
import '../models/word.dart';

class WordTile extends StatefulWidget {
  final Word word;
  final VoidCallback? onDelete;

  const WordTile({super.key, required this.word, this.onDelete});

  @override
  State<WordTile> createState() => _WordTileState();
}

class _WordTileState extends State<WordTile> with AutomaticKeepAliveClientMixin {
  bool _expanded = false;
  bool _isHovered = false;

  // Memoização para evitar reconstrução desnecessária
  late final Widget _germanText;
  late final Widget _portugueseText;
  late final Widget? _exampleWidget;

  @override
  bool get wantKeepAlive => true; // Mantém o estado quando fora da tela

  @override
  void initState() {
    super.initState();
    _initializeWidgets();
  }

  void _initializeWidgets() {
    // Pré-constrói widgets que não mudam
    _germanText = Text(
      widget.word.german,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: Colors.black87,
        letterSpacing: 0.1,
      ),
    );

    _portugueseText = Text(
      widget.word.portuguese,
      style: TextStyle(
        color: Colors.grey[700],
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.3,
      ),
    );

    _exampleWidget = widget.word.example != null && widget.word.example!.isNotEmpty
        ? _ExampleWidget(example: widget.word.example!)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessário para AutomaticKeepAliveClientMixin

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150), // Reduzido de 200ms
        curve: Curves.easeOut, // Curve mais simples
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
            onTap: _toggleExpanded,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _germanText),
                      _ExpandIcon(expanded: _expanded),
                    ],
                  ),
                  if (_expanded) ...[
                    const SizedBox(height: 12),
                    _portugueseText,
                    if (_exampleWidget != null) _exampleWidget!,
                    if (widget.onDelete != null) _DeleteButton(onDelete: widget.onDelete!),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setHovered(bool hovered) {
    if (_isHovered != hovered) {
      setState(() => _isHovered = hovered);
    }
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }
}

// Widget separado para o ícone de expansão (evita rebuild desnecessário)
class _ExpandIcon extends StatelessWidget {
  final bool expanded;

  const _ExpandIcon({required this.expanded});

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: expanded ? 0.5 : 0.0,
      duration: const Duration(milliseconds: 150),
      child: Icon(
        Icons.expand_more_rounded,
        color: Colors.grey[600],
        size: 24,
      ),
    );
  }
}

// Widget separado para o exemplo (lazy loading)
class _ExampleWidget extends StatelessWidget {
  final String example;

  const _ExampleWidget({required this.example});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          example,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey[600],
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

// Widget separado para o botão de deletar
class _DeleteButton extends StatelessWidget {
  final VoidCallback onDelete;

  const _DeleteButton({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: IconButton(
          icon: Icon(Icons.delete_outline_rounded, color: Colors.red[400]),
          onPressed: onDelete,
          tooltip: 'Deletar palavra',
        ),
      ),
    );
  }
} 