import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/flashcards_screen.dart';
import 'screens/articles_training_screen.dart';
import 'screens/translation_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'firebase_options.dart';
import 'services/firestore_service.dart';
import 'services/activity_service.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Pre-carrega dados para melhor performance
  await _preloadData();
  
  runApp(const MyApp());
}

// Pre-carrega dados críticos para melhor performance inicial
Future<void> _preloadData() async {
  try {
    // Pre-carrega palavras no cache
    await FirestoreService().preloadData();
    
    // Pre-carrega estatísticas de atividade
    await ActivityService().getActiveDays();
    
    // Inicializa serviço de áudio
    await AudioService().initialize();
  } catch (e) {
    print('Erro ao pre-carregar dados: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 12 Pro Max base
      minTextAdapt: true,
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bias Deutsches Wörterbuch',
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            primary: Colors.black,
            secondary: Color(0xFFFFD700), // amarelo sutil
            onPrimary: Colors.white,
            onSecondary: Colors.black,
          ),
          textTheme: GoogleFonts.dancingScriptTextTheme().copyWith(
            bodyLarge: GoogleFonts.lato(),
            bodyMedium: GoogleFonts.lato(),
            bodySmall: GoogleFonts.lato(),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            elevation: 0,
            titleTextStyle: GoogleFonts.dancingScript(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 28.sp,
            ),
          ),
          scaffoldBackgroundColor: Colors.white,
          // Otimizações de performance
          useMaterial3: true,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            },
          ),
        ),
        home: const MainTabScreen(),
      ),
    );
  }
}

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;

  // Cache das telas para evitar reconstrução
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Inicializa as telas uma única vez
    _screens = [
      const HomeScreen(),
      const FlashcardsScreen(),
      const ArticlesTrainingScreen(),
      const TranslationScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Limpa recursos dos serviços
    FirestoreService().dispose();
    ActivityService().dispose();
    AudioService().dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200), // Animação mais rápida
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        physics: const NeverScrollableScrollPhysics(), // Desabilita swipe para evitar conflitos
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onTabTapped,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded),
              label: 'Dicionário',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.style_rounded),
              label: 'Flashcards',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_rounded),
              label: 'Artigos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.translate_rounded),
              label: 'Tradutor',
            ),
          ],
        ),
      ),
    );
  }
} 