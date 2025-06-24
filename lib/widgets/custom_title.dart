import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTitle extends StatelessWidget {
  const CustomTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.black,
            Colors.red[700]!,
            Color(0xFFFFD700),
            Colors.red[700]!,
            Colors.black,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bandeira da Alemanha (esquerda)
          Container(
            width: 32,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  Colors.red[700]!,
                  Color(0xFFFFD700),
                ],
              ),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
          // Título centralizado
          Expanded(
            child: Center(
              child: Text(
                'Bias Deutsches Wörterbuch',
                style: GoogleFonts.dancingScript(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bandeira da Alemanha (direita)
          Container(
            width: 32,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  Colors.red[700]!,
                  Color(0xFFFFD700),
                ],
              ),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
        ],
      ),
    );
  }
} 