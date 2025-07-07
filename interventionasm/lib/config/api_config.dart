class ApiConfig {
  // For Android emulator, use 10.0.2.2 instead of 127.0.0.1
  // For iOS simulator, localhost usually works
  // For real devices, use your computer's local IP address (e.g., 192.168.1.100)
  
  // Change this value based on your environment:
  // - Android emulator: 'http://10.0.2.2:8000'
  // - iOS simulator: 'http://127.0.0.1:8000' or 'http://localhost:8000'
  // - Real device: 'http://YOUR_COMPUTER_IP:8000' (e.g., 'http://192.168.1.100:8000')
  
  static const String baseUrl = 'http://127.0.0.1:8000';
  
  // API endpoints
  static const String apiUrl = '$baseUrl/api';
  
  // Specific endpoints
  static const String loginUrl = '$apiUrl/login';
  static const String registerUrl = '$apiUrl/register';
  static const String userUrl = '$apiUrl/user';
  static const String refreshUrl = '$apiUrl/refresh';
  static const String activateUrl = '$apiUrl/activate';
  static const String stationsUrl = '$apiUrl/stations';
  static const String articlesUrl = '$apiUrl/articles';
  static const String achatsUrl = '$apiUrl/achats';
  static const String transfertsUrl = '$apiUrl/transferts';
  static const String inventairesUrl = '$apiUrl/inventaires';
  static const String fournisseursUrl = '$apiUrl/fournisseurs';
  static const String usersUrl = '$apiUrl/users';
  static const String rolesUrl = '$apiUrl/roles';
} 