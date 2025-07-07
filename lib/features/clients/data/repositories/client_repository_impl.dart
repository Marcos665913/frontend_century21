// lib/features/clients/data/repositories/client_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:flutter_crm_app/core/utils/failure.dart';
import 'package:flutter_crm_app/features/clients/data/data_sources/client_remote_data_source.dart';
import 'package:flutter_crm_app/features/clients/data/models/client_model.dart';
import 'package:flutter_crm_app/features/clients/data/repositories/client_repository.dart';
import 'package:fpdart/fpdart.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientRemoteDataSource _remoteDataSource;
  ClientRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<ClientModel>>> getClients() async {
    try {
      final clients = await _remoteDataSource.getClients();
      return right(clients);
    } on ServerFailure catch (e) {
      return left(e);
    } on DioException catch (e) {
      return left(ServerFailure(e.response?.data?['mensaje'] ?? 'Error de red', statusCode: e.response?.statusCode));
    } catch (e) {
      return left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ClientModel>> addClient(Map<String, dynamic> clientFields) async {
    try {
      final newClient = await _remoteDataSource.addClient(clientFields);
      return right(newClient);
    } on ServerFailure catch (e) {
      return left(e);
    } on DioException catch (e) {
       return left(ServerFailure(e.response?.data?['mensaje'] ?? 'Error de red', statusCode: e.response?.statusCode));
    } catch (e) {
      return left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ClientModel>> updateClient(String clientId, Map<String, dynamic> clientFields) async {
    try {
      final updatedClient = await _remoteDataSource.updateClient(clientId, clientFields);
      return right(updatedClient);
    } on ServerFailure catch (e) {
      return left(e);
    } on DioException catch (e) {
       return left(ServerFailure(e.response?.data?['mensaje'] ?? 'Error de red', statusCode: e.response?.statusCode));
    } catch (e) {
      return left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteClient(String clientId) async {
    try {
      await _remoteDataSource.deleteClient(clientId);
      return right(unit);
    } on ServerFailure catch (e) {
      return left(e);
    } on DioException catch (e) {
       return left(ServerFailure(e.response?.data?['mensaje'] ?? 'Error de red', statusCode: e.response?.statusCode));
    } catch (e) {
      return left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }
}