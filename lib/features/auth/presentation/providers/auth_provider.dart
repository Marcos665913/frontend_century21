// lib/features/auth/presentation/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_crm_app/core/constants/api_endpoints.dart'; // <-- IMPORT AÑADIDO
import 'package:flutter_crm_app/core/network/dio_client.dart';
import 'package:flutter_crm_app/core/services/firebase_messaging_service.dart';
import 'package:flutter_crm_app/core/local_storage/secure_storage_service.dart';
import 'package:flutter_crm_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:flutter_crm_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_crm_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_crm_app/features/auth/presentation/providers/auth_state.dart';

// Providers de inyección de dependencias (sin cambios)
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.read(dioProvider));
});
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authRemoteDataSourceProvider), ref.read(secureStorageServiceProvider));
});

// Provider del Notifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider), ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthNotifier(this._authRepository, this._ref) : super(const AuthState()) {
    checkAuthStatus();
  }
  
  Future<void> _registerFcmToken() async {
    try {
      final fcmToken = await FirebaseMessagingService().getToken();
      if (fcmToken != null) {
        // --- INICIO DE LA CORRECCIÓN ---
        // Usamos la constante en lugar de un texto quemado
        await _ref.read(dioProvider).post(ApiEndpoints.fcmToken, data: {'fcmToken': fcmToken});
        // --- FIN DE LA CORRECCIÓN ---
        print('[Flutter] Token FCM enviado al backend con éxito.');
      }
    } catch (e) {
      print('[Flutter] ERROR al enviar el token FCM al backend: $e');
    }
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _authRepository.checkAuthStatus();
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.unauthenticated),
      (user) {
        if (user != null) {
          state = state.copyWith(status: AuthStatus.authenticated, user: user);
          _registerFcmToken(); 
        } else {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      },
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, clearErrorMessage: true);
    final result = await _authRepository.login(email, password);
    result.fold(
      (failure) {
        state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: failure.message);
      },
      (_) async {
        await checkAuthStatus();
      },
    );
  }

  Future<void> register(String name, String email, String password, String role) async {
    state = state.copyWith(status: AuthStatus.loading, clearErrorMessage: true);
    final result = await _authRepository.register(name, email, password, role);
     await result.fold(
      (failure) async {
        state = state.copyWith(status: AuthStatus.error, errorMessage: failure.message, clearUser: true);
      },
      (_) async {
        final profileResult = await _authRepository.getUserProfile();
        profileResult.fold(
          (failure) {
             state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: failure.message, clearUser: true);
          },
          (user) async {
            state = state.copyWith(status: AuthStatus.authenticated, user: user, clearErrorMessage: true);
            await _registerFcmToken();
          }
        );
      },
    );
  }
  
  Future<void> fetchUserProfile() async {
    if (state.status == AuthStatus.authenticated) {
      state = state.copyWith(status: AuthStatus.loading);
      final result = await _authRepository.getUserProfile();
      result.fold(
        (failure) {
          state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: failure.message, clearUser: true);
        },
        (user) {
          state = state.copyWith(status: AuthStatus.authenticated, user: user, clearErrorMessage: true);
        }
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _authRepository.logout();
    result.fold(
      (failure) {
        state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: failure.message, clearUser: true);
      },
      (_) {
        state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true, clearErrorMessage: true);
      },
    );
  }
}