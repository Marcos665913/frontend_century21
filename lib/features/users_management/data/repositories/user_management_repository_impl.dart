import 'package:flutter_crm_app/core/utils/failure.dart';
import 'package:flutter_crm_app/features/auth/data/models/user_model.dart'; // <-- IMPORT AÑADIDO
import 'package:flutter_crm_app/features/users_management/data/data_sources/user_management_remote_data_source.dart';
import 'package:flutter_crm_app/features/users_management/domain/repositories/user_management_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserManagementRepositoryImpl implements UserManagementRepository {
  final UserManagementRemoteDataSource _remoteDataSource;
  UserManagementRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<UserModel>>> getAllUsers() async {
    try {
      final users = await _remoteDataSource.getAllUsers();
      return right(users);
    } on ServerFailure catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<Failure, Unit>> assignRole(String userId, String role) async {
    try {
      await _remoteDataSource.assignRole(userId, role);
      return right(unit);
    } on ServerFailure catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<Failure, Unit>> deactivateUser(String userId) async {
    try {
      await _remoteDataSource.deactivateUser(userId);
      return right(unit);
    } on ServerFailure catch(e) {
      return left(e);
    }
  }

  @override
  Future<Either<Failure, Unit>> reactivateUser(String userId) async {
    try {
      await _remoteDataSource.reactivateUser(userId);
      return right(unit);
    } on ServerFailure catch(e) {
      return left(e);
    }
  }
}
