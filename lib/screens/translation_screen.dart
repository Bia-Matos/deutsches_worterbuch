import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/translation_service.dart';
import '../widgets/custom_title.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> with TickerProviderStateMixin {
  final TextEditingController _portugueseController = TextEditingController();
  final TextEditingController _germanController = TextEditingController();
  
  bool _isTranslating = false;
  bool _isTranslatingToGerman = false;
  bool _isTranslatingToPortuguese = false;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    _fadeController.forward();
    _slideController.forward();
  }
  
  @override
  void dispose() {
    _portugueseController.dispose();
    _germanController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
  
  Future<void> _translateToGerman() async {
    if (_portugueseController.text.trim().isEmpty) return;
    
    setState(() {
      _isTranslating = true;
      _isTranslatingToGerman = true;
    });
    
    try {
      final translation = await TranslationService.translateToGerman(
        _portugueseController.text.trim(),
      );
      
      if (translation != null) {
        setState(() {
          _germanController.text = translation;
        });
      } else {
        _showErrorSnackBar('Erro ao traduzir. Tente novamente.');
      }
    } catch (e) {
      _showErrorSnackBar('Erro na tradução: $e');
    } finally {
      setState(() {
        _isTranslating = false;
        _isTranslatingToGerman = false;
      });
    }
  }
  
  Future<void> _translateToPortuguese() async {
    if (_germanController.text.trim().isEmpty) return;
    
    setState(() {
      _isTranslating = true;
      _isTranslatingToPortuguese = true;
    });
    
    try {
      final translation = await TranslationService.translateToPortuguese(
        _germanController.text.trim(),
      );
      
      if (translation != null) {
        setState(() {
          _portugueseController.text = translation;
        });
      } else {
        _showErrorSnackBar('Erro ao traduzir. Tente novamente.');
      }
    } catch (e) {
      _showErrorSnackBar('Erro na tradução: $e');
    } finally {
      setState(() {
        _isTranslating = false;
        _isTranslatingToPortuguese = false;
      });
    }
  }
  
  void _clearText() {
    setState(() {
      _portugueseController.clear();
      _germanController.clear();
    });
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const CustomTitle(),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header elegante com gradiente
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(28.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF667eea),
                        const Color(0xFF764ba2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667eea).withValues(alpha: 0.3),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          Icons.translate_rounded,
                          size: 48.w,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Tradutor Inteligente',
                        style: GoogleFonts.lato(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Traduza entre português e alemão',
                        style: GoogleFonts.lato(
                          fontSize: 16.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 32.h),
                
                // Campo Português
                _buildLanguageField(
                  controller: _portugueseController,
                  label: 'Português',
                  hint: 'Digite o texto em português...',
                  flag: '🇧🇷',
                  gradient: LinearGradient(
                    colors: [Colors.green[400]!, Colors.green[600]!],
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      Future.delayed(const Duration(milliseconds: 1000), () {
                        if (_portugueseController.text == value) {
                          _translateToGerman();
                        }
                      });
                    }
                  },
                ),
                
                SizedBox(height: 24.h),
                
                // Botões de ação com design melhorado
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        onPressed: _isTranslating ? null : _translateToGerman,
                        icon: _isTranslatingToGerman 
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.arrow_downward_rounded),
                        label: _isTranslatingToGerman ? 'Traduzindo...' : 'Traduzir → Alemão',
                        gradient: LinearGradient(
                          colors: [Colors.blue[500]!, Colors.blue[700]!],
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 12.w),
                    
                    Expanded(
                      child: _buildActionButton(
                        onPressed: _isTranslating ? null : _translateToPortuguese,
                        icon: _isTranslatingToPortuguese 
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.arrow_upward_rounded),
                        label: _isTranslatingToPortuguese ? 'Traduzindo...' : 'Traduzir → Português',
                        gradient: LinearGradient(
                          colors: [Colors.orange[500]!, Colors.orange[700]!],
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 24.h),
                
                // Campo Alemão
                _buildLanguageField(
                  controller: _germanController,
                  label: 'Alemão',
                  hint: 'Digite o texto em alemão...',
                  flag: '🇩🇪',
                  gradient: LinearGradient(
                    colors: [Colors.red[400]!, Colors.red[600]!],
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      Future.delayed(const Duration(milliseconds: 1000), () {
                        if (_germanController.text == value) {
                          _translateToPortuguese();
                        }
                      });
                    }
                  },
                ),
                
                SizedBox(height: 32.h),
                
                // Botão limpar com design melhorado
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _clearText,
                      icon: const Icon(Icons.clear_rounded),
                      label: Text(
                        'Limpar Campos',
                        style: GoogleFonts.lato(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey[700],
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 36.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required Widget icon,
    required String label,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          gradient: gradient,
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: icon,
          label: Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: 18.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.r),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildLanguageField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String flag,
    required Gradient gradient,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do campo com gradiente
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
            ),
            child: Row(
              children: [
                Text(
                  flag,
                  style: TextStyle(fontSize: 24.sp),
                ),
                SizedBox(width: 16.w),
                Text(
                  label,
                  style: GoogleFonts.lato(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Campo de texto
          Padding(
            padding: EdgeInsets.all(24.w),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              maxLines: 4,
              minLines: 3,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.lato(
                  color: Colors.grey[400],
                  fontSize: 16.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: GoogleFonts.lato(
                fontSize: 16.sp,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 