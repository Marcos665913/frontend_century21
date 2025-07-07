// lib/features/clients/domain/repositories/client_repository.dart
import 'package:flutter_crm_app/core/utils/failure.dart';
import 'package:flutter_crm_app/features/clients/data/models/client_model.dart';
import 'package:fpdart/fpdart.dart';

abstract class ClientRepository {
  Future<Either<Failure, List<ClientModel>>> getClients();
  Future<Either<Failure, ClientModel>> addClient(Map<String, dynamic> clientFields);
  Future<Either<Failure, ClientModel>> updateClient(String clientId, Map<String, dynamic> clientFields);
  Future<Either<Failure, Unit>> deleteClient(String clientId);
}