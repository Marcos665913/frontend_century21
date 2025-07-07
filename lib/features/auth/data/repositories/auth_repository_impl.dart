// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:flutter_crm_app/core/local_storage/secure_storage_service.dart';
import 'package:flutter_crm_app/core/utils/failure.dart';
import 'package:flutter_crm_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:flutter_crm_app/features/auth/data/models/user_model.dart';
import 'package:flutter_crm_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorageService;

  AuthRepositoryImpl(this._remoteDataSource, this._secureStorageService);

  @override
  Future<Either<Failure, Unit>> login(String email, String password) async {
    try {
      final authResponse = await _remoteDataSource.login(email, password);
      await _secureStorageService.saveAuthToken(authResponse.token);
      final userProfile = await _remoteDataSource.getUserProfile();
      await _secureStorageService.saveUserRole(userProfile.role);
      return right(unit);
    } on ServerFailure catch (e) {
      return left(e); // El data source ya lanza un ServerFailure
    } on DioException catch(e){
      return left(ServerFailure.fromDioException(e)); // Usamos nuestro helper
    } catch (e) {
      return left(ServerFailure('Error desconocido durante el login: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> register(String name, String email, String password, String role) async {
    try {
      final authResponse = await _remoteDataSource.register(name, email, password, role);
      await _secureStorageService.saveAuthToken(authResponse.token);
      final userProfile = await _remoteDataSource.getUserProfile();
      await _secureStorageService.saveUserRole(userProfile.role);
      return right(unit);
    } on ServerFailure catch (e) {
      return left(e);
    } on DioException catch(e){
      return left(ServerFailure.fromDioException(e));
    } catch (e) {
      return left(ServerFailure('Error desconocido durante el registro: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getUserProfile() async {
    try {
      final userModel = await _remoteDataSource.getUserProfile();
      await _secureStorageService.saveUserRole(userModel.role);
      return right(userModel);
    } on ServerFailure catch (e) {
      return left(e);
    } on DioException catch(e){
      return left(ServerFailure.fromDioException(e));
    } catch (e) {
      return left(ServerFailure('Error desconocido obteniendo perfil: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _secureStorageService.deleteAll();
      return right(unit);
    } catch (e) {
      // Aquí usamos CacheFailure porque el error es del almacenamiento local.
      return left(CacheFailure('Error al cerrar sesión: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, UserModel?>> checkAuthStatus() async {
    try {
      final token = await _secureStorageService.getAuthToken();
      if (token == null || token.isEmpty) {
        return right(null);
      }
      final userProfile = await _remoteDataSource.getUserProfile();
      await _secureStorageService.saveUserRole(userProfile.role);
      return right(userProfile);
    } on ServerFailure catch (e) {
      await _secureStorageService.deleteAll();
      return left(e);
    } on DioException catch(e){
      await _secureStorageService.deleteAll();
      return left(ServerFailure.fromDioException(e));
    } catch (e) {
      await _secureStorageService.deleteAll();
      return left(ServerFailure('Error verificando estado: ${e.toString()}'));
    }
  }
}