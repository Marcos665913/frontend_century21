// lib/features/auth/data/data_sources/auth_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:flutter_crm_app/core/constants/api_endpoints.dart';
import 'package:flutter_crm_app/core/utils/failure.dart';
import 'package:flutter_crm_app/features/auth/data/models/auth_response.dart';
import 'package:flutter_crm_app/features/auth/data/models/user_model.dart';


abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register(String name, String email, String password, String role);
  Future<UserModel> getUserProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Error de inicio de sesión',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerFailure(
        e.response?.data?['message'] ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<AuthResponse> register(String name, String email, String password, String role) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: {'name': name, 'email': email, 'password': password, 'role': role},
      );
      if (response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Error de registro',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerFailure(
        e.response?.data?['message'] ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserModel> getUserProfile() async {
    try {
      // Este endpoint requiere que el token ya esté en el interceptor de Dio
      final response = await _dio.get(ApiEndpoints.userProfile);
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Error al obtener perfil',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerFailure(
        e.response?.data?['message'] ?? e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}