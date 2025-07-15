import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class AudioButton extends StatefulWidget {
  final String text;
  final double size;
  final Color? color;
  final bool showLabel;

  const AudioButton({
    super.key,
    required this.text,
    this.size = 24,
    this.color,
    this.showLabel = false,
  });

  @override
  State<AudioButton> createState() => _AudioButtonState();
}

class _AudioButtonState extends State<AudioButton> {
  final AudioService _audioService = AudioService();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioService.initialize();
  }

  Future<void> _playAudio() async {
    if (_isPlaying) return;

    setState(() {
      _isPlaying = true;
    });

    try {
      await _audioService.speak(widget.text);
    } finally {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _playAudio,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isPlaying 
              ? (widget.color ?? Colors.blue).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isPlaying ? Icons.volume_up : Icons.volume_up_outlined,
                key: ValueKey(_isPlaying),
                size: widget.size,
                color: widget.color ?? Colors.blue[600],
              ),
            ),
            if (widget.showLabel) ...[
              const SizedBox(width: 4),
              Text(
                'Ouvir',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.color ?? Colors.blue[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 