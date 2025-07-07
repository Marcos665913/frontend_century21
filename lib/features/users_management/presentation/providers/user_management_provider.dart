  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:flutter_crm_app/core/network/dio_client.dart';
  import 'package:flutter_crm_app/features/users_management/data/data_sources/user_management_remote_data_source.dart';
  import 'package:flutter_crm_app/features/users_management/data/repositories/user_management_repository_impl.dart';
  import 'package:flutter_crm_app/features/users_management/domain/repositories/user_management_repository.dart';
  import 'package:flutter_crm_app/features/users_management/presentation/providers/user_management_state.dart';

  // Providers para inyección de dependencias
  final userManagementRemoteDataSourceProvider =
      Provider<UserManagementRemoteDataSource>((ref) {
    return UserManagementRemoteDataSourceImpl(ref.read(dioProvider));
  });

  final userManagementRepositoryProvider = Provider<UserManagementRepository>((ref) {
    return UserManagementRepositoryImpl(
        ref.read(userManagementRemoteDataSourceProvider));
  });

  // Provider del Notifier
  final userManagementNotifierProvider =
      StateNotifierProvider<UserManagementNotifier, UserManagementState>((ref) {
    return UserManagementNotifier(ref.read(userManagementRepositoryProvider));
  });

  class UserManagementNotifier extends StateNotifier<UserManagementState> {
    final UserManagementRepository _repository;
    UserManagementNotifier(this._repository)
        : super(const UserManagementState());

    Future<void> fetchUsers() async {
      state = state.copyWith(status: UserManagementStatus.loading);
      final result = await _repository.getAllUsers();
      result.fold(
        (failure) {
          state = state.copyWith(
              status: UserManagementStatus.error, errorMessage: failure.message);
        },
        (users) {
          state = state.copyWith(status: UserManagementStatus.loaded, users: users);
        },
      );
    }

    Future<bool> assignRole(String userId, String role) async {
      state = state.copyWith(status: UserManagementStatus.submitting);
      final result = await _repository.assignRole(userId, role);
      return result.fold(
        (failure) {
          state = state.copyWith(
              status: UserManagementStatus.error, errorMessage: failure.message);
          return false;
        },
        (_) {
          // Éxito. Recargamos la lista de usuarios para ver el cambio.
          fetchUsers();
          return true;
        },
      );
    }

    // --- INICIO DE CÓDIGO AÑADIDO ---
    Future<void> deactivateUser(String userId) async {
      state = state.copyWith(status: UserManagementStatus.submitting);
      final result = await _repository.deactivateUser(userId);
      result.fold(
        (failure) => state = state.copyWith(status: UserManagementStatus.error, errorMessage: failure.message),
        (_) => fetchUsers(), // Recargar la lista para mostrar el cambio de estado
      );
    }

    Future<void> reactivateUser(String userId) async {    
      state = state.copyWith(status: UserManagementStatus.submitting);
      final result = await _repository.reactivateUser(userId);
      result.fold(
        (failure) => state = state.copyWith(status: UserManagementStatus.error, errorMessage: failure.message),
        (_) => fetchUsers(),
      );
    }
    // --- FIN DE CÓDIGO AÑADIDO ---
  }
