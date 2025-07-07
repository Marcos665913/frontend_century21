import 'package:dio/dio.dart';
import 'package:flutter_crm_app/core/constants/api_endpoints.dart';
import 'package:flutter_crm_app/core/utils/failure.dart';
import 'package:flutter_crm_app/features/auth/data/models/user_model.dart';

abstract class UserManagementRemoteDataSource {
  Future<List<UserModel>> getAllUsers();
  Future<void> assignRole(String userId, String role);
  Future<void> deactivateUser(String userId);
  Future<void> reactivateUser(String userId);
}

class UserManagementRemoteDataSourceImpl implements UserManagementRemoteDataSource {
  final Dio _dio;
  UserManagementRemoteDataSourceImpl(this._dio);

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _dio.get(ApiEndpoints.allUsers);
      return (response.data as List).map((e) => UserModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ServerFailure.fromDioException(e);
    }
  }

  @override
  Future<void> assignRole(String userId, String role) async {
    try {
      await _dio.post(ApiEndpoints.assignRole, data: {'userId': userId, 'role': role});
    } on DioException catch (e) {
      throw ServerFailure.fromDioException(e);
    }
  }

  @override
  Future<void> deactivateUser(String userId) async {
    try {
      // La ruta DELETE ahora desactiva al usuario en el backend
      await _dio.delete(ApiEndpoints.userById(userId));
    } on DioException catch (e) {
      throw ServerFailure.fromDioException(e);
    }
  }

  @override
  Future<void> reactivateUser(String userId) async {
    try {
      // La ruta PATCH ahora reactiva al usuario en el backend
      await _dio.patch(ApiEndpoints.reactivateUser(userId));
    } on DioException catch (e) {
      throw ServerFailure.fromDioException(e);
    }
  }
}