class ApiEndpoints {
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';

  // User Profile & Management
  static const String userProfile = '/users/profile';
  static const String allUsers = '/users/all';
  static const String assignRole = '/roles/assign';
  static const String fcmToken = '/users/fcm-token';
  // --- ENDPOINTS AÑADIDOS ---
  static String userById(String userId) => '/users/$userId'; // Para DELETE (desactivar)
  static String reactivateUser(String userId) => '/users/$userId/reactivate'; // Para PATCH (reactivar)

  // Clients
  static const String clients = '/clients';
  static String clientById(String clientId) => '/clients/$clientId';
  static String clientFields(String clientId) => '/clients/$clientId/fields';

  // Custom Fields
  static const String customFields = '/custom-fields';
  static String customFieldById(String id) => '/custom-fields/$id';

  // Reminders
  static const String reminders = '/reminders';
  static String reminderById(String id) => '/reminders/$id';
}