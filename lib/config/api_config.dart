class ApiConfig {
  // Google Translate API Key
  // Para obter uma chave gratuita:
  // 1. Acesse: https://console.cloud.google.com/
  // 2. Crie um projeto ou selecione um existente
  // 3. Ative a Cloud Translation API
  // 4. Crie credenciais (API Key)
  // 5. Substitua a chave abaixo
  static const String googleTranslateApiKey = 'YOUR_GOOGLE_TRANSLATE_API_KEY';
  
  // Para desenvolvimento, você pode usar uma chave de teste
  // Mas para produção, configure uma chave real
  static const bool useTestMode = true;
} 