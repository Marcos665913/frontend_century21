// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_crm_app/core/config/app_config.dart';
import 'package:flutter_crm_app/core/local_storage/secure_storage_service.dart';

// Provider para el servicio de almacenamiento seguro
// Ya está definido en secure_storage_service.dart, así que lo usaremos directamente.

// Provider para Dio
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  final storageService = ref.read(secureStorageServiceProvider);

  dio.options = BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 15), // 15 segundos
    receiveTimeout: const Duration(seconds: 15), // 15 segundos
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  // --- Nuevo Log de Inicialización de Dio ---
  AppLogger.log('DIO INIT: Dio initialized with baseUrl: ${dio.options.baseUrl}');
  // ----------------------------------------

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Añadir token de autenticación si existe
        final token = await storageService.getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          AppLogger.log('Token added to header: Bearer $token');
        }
        AppLogger.log('Request: ${options.method} ${options.uri}');
        // --- Nuevo Log de URL Completa de Petición ---
        AppLogger.log('Full Request URL: ${options.baseUrl}${options.path}');
        // --------------------------------------------
        AppLogger.log('Request Data: ${options.data}');
        return handler.next(options); // Continuar con la petición
      },
      onResponse: (response, handler) {
        AppLogger.log('Response: ${response.statusCode} ${response.requestOptions.uri}');
        AppLogger.log('Response Data: ${response.data}');
        return handler.next(response); // Continuar con la respuesta
      },
      onError: (DioException e, handler) async {
        AppLogger.error('DioError: ${e.requestOptions.method} ${e.requestOptions.uri}');
        AppLogger.error('Error Message: ${e.message}');
        // --- Nuevo Log de URL Completa de Error ---
        AppLogger.error('Full Error URL: ${e.requestOptions.baseUrl}${e.requestOptions.path}');
        // ------------------------------------------
        if (e.response != null) {
          AppLogger.error('Error Response Data: ${e.response?.data}');
          AppLogger.error('Error Status Code: ${e.response?.statusCode}');
          if (e.response?.statusCode == 401) {
            await storageService.deleteAll(); // Limpiar token y rol
            AppLogger.warn('Unauthorized access (401). Token cleared.');
          }
        }
        return handler.next(e); // Continuar con el error
      },
    ),
  );

  return dio;
});

// Utilidad simple de Logger (Ahora con print() descomentado para depuración)
class AppLogger {
  static void log(String message) {
    print('[LOG] $message'); // Descomentado para ver logs en consola
  }

  static void warn(String message) {
    print('[WARN] $message'); // Descomentado
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    print('[ERROR] $message'); // Descomentado
    if (error != null) {
      print('  Error: $error');
    }
    if (stackTrace != null) {
      print('  StackTrace: $stackTrace');
    }
  }
}