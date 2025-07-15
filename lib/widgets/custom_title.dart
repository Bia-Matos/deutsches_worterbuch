import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTitle extends StatelessWidget {
  const CustomTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bandeira da Alemanha como ícone
          Container(
            width: 28,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!, width: 0.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3.5),
              child: Column(
                children: [
                  Expanded(child: Container(color: Colors.black)),
                  Expanded(child: Container(color: Colors.red[700])),
                  Expanded(child: Container(color: const Color(0xFFFFD700))),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Título elegante
          Text(
            'Deutsch Lernen',
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: 0.2,
            ),
          ),
          
          const Spacer(),
          
          // Avatar da usuária - design mais sutil
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue[100]!,
                  Colors.blue[200]!,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/profile.jpg',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback mais sutil com ícone de pessoa
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue[100]!,
                          Colors.blue[200]!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 20,
                      color: Colors.blue[600],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
} 