// lib/core/utils/failure.dart
import 'package:dio/dio.dart';

abstract class Failure {
  final String message;
  final int? statusCode;
  const Failure(this.message, {this.statusCode});
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});

  factory ServerFailure.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerFailure('Tiempo de espera de conexión agotado. Revisa tu conexión a internet.');
      
      case DioExceptionType.badResponse:
        // --- INICIO DE LA CORRECCIÓN ---
        // Hacemos nuestro manejador más robusto.
        final responseData = e.response?.data;
        String errorMessage;

        if (responseData is Map<String, dynamic>) {
          // Si es un JSON, buscamos la clave 'mensaje'.
          errorMessage = responseData['mensaje'] ?? 'El servidor respondió con un error pero sin mensaje.';
        } else if (responseData is String) {
          // Si es texto plano, usamos ese texto como el mensaje.
          errorMessage = responseData;
        } else {
          // Si es cualquier otra cosa, usamos un mensaje genérico.
          errorMessage = 'Error del servidor. Inténtalo de nuevo más tarde.';
        }
        
        return ServerFailure(errorMessage, statusCode: e.response?.statusCode);
        // --- FIN DE LA CORRECCIÓN ---

      case DioExceptionType.cancel:
        return const ServerFailure('La petición a la API fue cancelada.');

      case DioExceptionType.connectionError:
         return const ServerFailure('Error de conexión. Asegúrate de que el servidor esté accesible.');
         
      case DioExceptionType.unknown:
      default:
        // Este error ahora debería ocurrir con menos frecuencia gracias al arreglo de CORS.
        return const ServerFailure('Ocurrió un error inesperado de red.');
    }
  }
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}