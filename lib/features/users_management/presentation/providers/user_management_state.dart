// lib/features/users_management/presentation/providers/user_management_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_crm_app/features/auth/data/models/user_model.dart';

enum UserManagementStatus { initial, loading, loaded, error, submitting }

class UserManagementState extends Equatable {
  final UserManagementStatus status;
  final List<UserModel> users;
  final String? errorMessage;

  const UserManagementState({
    this.status = UserManagementStatus.initial,
    this.users = const [],
    this.errorMessage,
  });

  UserManagementState copyWith({
    UserManagementStatus? status,
    List<UserModel>? users,
    String? errorMessage,
  }) {
    return UserManagementState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, users, errorMessage];
}