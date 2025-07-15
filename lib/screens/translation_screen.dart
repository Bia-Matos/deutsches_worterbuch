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

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController _portugueseController = TextEditingController();
  final TextEditingController _germanController = TextEditingController();
  
  bool _isTranslating = false;
  bool _isTranslatingToGerman = false;
  bool _isTranslatingToPortuguese = false;
  
  @override
  void dispose() {
    _portugueseController.dispose();
    _germanController.dispose();
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
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const CustomTitle(),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header elegante
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.95),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.translate_rounded,
                    size: 48.w,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Tradutor Inteligente',
                    style: GoogleFonts.lato(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Traduza entre português e alemão',
                    style: GoogleFonts.lato(
                      fontSize: 16.sp,
                      color: Colors.white.withValues(alpha: 0.8),
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
            
            // Botões de ação
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
                      colors: [Colors.blue[600]!, Colors.blue[800]!],
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
                      colors: [Colors.green[600]!, Colors.green[800]!],
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
            
            // Botão limpar
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
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
                    padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
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
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ).copyWith(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
        ),
      ),
    );
  }
  
  Widget _buildLanguageField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String flag,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do campo
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                Text(
                  flag,
                  style: TextStyle(fontSize: 20.sp),
                ),
                SizedBox(width: 12.w),
                Text(
                  label,
                  style: GoogleFonts.lato(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          // Campo de texto
          Padding(
            padding: EdgeInsets.all(20.w),
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
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 