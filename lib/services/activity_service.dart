import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class ActivityService {
  static final ActivityService _instance = ActivityService._internal();
  factory ActivityService() => _instance;
  ActivityService._internal();

  final CollectionReference _activityCollection =
      FirebaseFirestore.instance.collection('user_activity');

  // Cache local para evitar queries desnecessárias
  int? _cachedActiveDays;
  DateTime? _lastCacheUpdate;
  static const Duration _cacheExpiration = Duration(minutes: 10);

  // Debounce para evitar múltiplas escritas
  Timer? _debounceTimer;
  final Set<String> _pendingActivities = {};
  static const Duration _debounceDelay = Duration(seconds: 3);

  // Throttling para limitar frequência de registros
  DateTime? _lastActivityRecord;
  static const Duration _throttleDelay = Duration(minutes: 1);

  // Registra atividade do usuário com otimizações
  Future<void> recordActivity(String activityType) async {
    print('[ActivityService] recordActivity chamado com activityType: $activityType');
    // Throttling: evita registrar atividades muito frequentes
    final now = DateTime.now();
    if (_lastActivityRecord != null && 
        now.difference(_lastActivityRecord!) < _throttleDelay) {
      print('[ActivityService] Throttle ativo. Ignorando registro.');
      return;
    }

    _pendingActivities.add(activityType);
    print('[ActivityService] _pendingActivities: \\${_pendingActivities.toList()}');
    _lastActivityRecord = now;

    // Debounce: aguarda um tempo antes de escrever no Firestore
    _debounceTimer?.cancel();
    print('[ActivityService] Iniciando debounce de $_debounceDelay.');
    _debounceTimer = Timer(_debounceDelay, () => _flushPendingActivities());
  }

  // Escreve atividades pendentes no Firestore
  Future<void> _flushPendingActivities() async {
    print('[ActivityService] _flushPendingActivities chamado.');
    if (_pendingActivities.isEmpty) {
      print('[ActivityService] Nenhuma atividade pendente para registrar.');
      return;
    }

    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    print('[ActivityService] Registrando atividades para o dia $dateKey: \\${_pendingActivities.toList()}');
    
    try {
      await _activityCollection.doc(dateKey).set({
        'date': dateKey,
        'timestamp': Timestamp.fromDate(today),
        'activities': FieldValue.arrayUnion(_pendingActivities.toList()),
      }, SetOptions(merge: true));
      
      print('[ActivityService] Atividades registradas com sucesso no Firestore.');
      _pendingActivities.clear();
      _invalidateCache();
    } catch (e) {
      print('[ActivityService] Erro ao registrar atividade: $e');
    }
  }

  // Calcula quantos dias o usuário esteve ativo com cache
  Future<int> getActiveDays() async {
    // Verifica cache primeiro
    if (_cachedActiveDays != null && 
        _lastCacheUpdate != null && 
        DateTime.now().difference(_lastCacheUpdate!) < _cacheExpiration) {
      return _cachedActiveDays!;
    }

    try {
      final querySnapshot = await _activityCollection.get();
      final activeDays = querySnapshot.docs.length;
      
      // Atualiza cache
      _cachedActiveDays = activeDays;
      _lastCacheUpdate = DateTime.now();
      
      return activeDays;
    } catch (e) {
      print('Erro ao calcular dias ativos: $e');
      return _cachedActiveDays ?? 0;
    }
  }

  // Stream otimizado para acompanhar mudanças
  Stream<int> getActiveDaysStream() {
    return _activityCollection.snapshots().map((snapshot) {
      final activeDays = snapshot.docs.length;
      
      // Atualiza cache quando recebe dados do stream
      _cachedActiveDays = activeDays;
      _lastCacheUpdate = DateTime.now();
      
      return activeDays;
    });
  }

  // Registra uso de flashcards com menor frequência
  Future<void> recordFlashcardActivity() async {
    await recordActivity('flashcards');
  }

  // Registra treino de artigos sem throttle/debounce
  Future<bool> recordArticleTrainingActivity() async {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    try {
      await _activityCollection.doc(dateKey).set({
        'date': dateKey,
        'timestamp': Timestamp.fromDate(today),
        'activities': FieldValue.arrayUnion(['article_training']),
      }, SetOptions(merge: true));
      print('[ActivityService] Article training activity recorded for $dateKey');
      return true;
    } catch (e) {
      print('[ActivityService] Error recording article training activity: $e');
      return false;
    }
  }

  // Força flush das atividades pendentes (útil quando app fecha)
  Future<void> forceFlush() async {
    _debounceTimer?.cancel();
    await _flushPendingActivities();
  }

  // Invalida cache
  void _invalidateCache() {
    _cachedActiveDays = null;
    _lastCacheUpdate = null;
  }

  // Limpa recursos
  void dispose() {
    _debounceTimer?.cancel();
    forceFlush();
  }
} 