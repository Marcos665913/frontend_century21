// lib/features/clients/data/data_sources/client_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_crm_app/core/constants/api_endpoints.dart';
import 'package:flutter_crm_app/core/utils/failure.dart';
import 'package:flutter_crm_app/features/clients/data/models/client_model.dart';
import 'package:flutter_crm_app/features/custom_fields/presentation/providers/custom_field_provider.dart';

abstract class ClientRemoteDataSource {
  Future<List<ClientModel>> getClients();
  Future<ClientModel> addClient(Map<String, dynamic> allClientData);
  Future<ClientModel> updateClient(String clientId, Map<String, dynamic> allClientData);
  Future<void> deleteClient(String clientId);
}

class ClientRemoteDataSourceImpl implements ClientRemoteDataSource {
  final Dio _dio;
  final ProviderRef _ref; // Ref para poder leer otros providers

  ClientRemoteDataSourceImpl(this._dio, this._ref);

  /// Helper para separar los campos estándar de los personalizados.
  (Map<String, dynamic>, Map<String, dynamic>) _separateFields(Map<String, dynamic> allFields) {
    // Leemos las definiciones de los campos personalizados que ya tenemos en el estado
    final customFieldDefs = _ref.read(customFieldNotifierProvider).fields;
    final customFieldKeys = customFieldDefs.map((e) => e.key).toSet();

    final standardFields = <String, dynamic>{};
    final customFieldsData = <String, dynamic>{};

    // Iteramos sobre todos los datos del formulario
    allFields.forEach((key, value) {
      if (customFieldKeys.contains(key)) {
        // Si la clave corresponde a un campo personalizado, va al mapa de customFieldsData
        customFieldsData[key] = value;
      } else {
        // Si no, es un campo estándar y va al mapa de fields
        standardFields[key] = value;
      }
    });

    return (standardFields, customFieldsData);
  }

  @override
  Future<List<ClientModel>> getClients() async {
    try {
      final response = await _dio.get(ApiEndpoints.clients);
      final clients = (response.data as List)
          .map((clientJson) => ClientModel.fromJson(clientJson))
          .toList();
      return clients;
    } on DioException catch (e) {
      throw ServerFailure.fromDioException(e);
    }
  }

  @override
  Future<ClientModel> addClient(Map<String, dynamic> allClientData) async {
    // ---- INICIO DE CÓDIGO DE DEPURACIÓN ----
    print('--- Intentando añadir cliente ---');
    final (fields, customFieldsData) = _separateFields(allClientData);
    final payload = {'fields': fields, 'customFieldsData': customFieldsData};
    
    print('Payload a enviar:');
    print(payload);
    // ---- FIN DE CÓDIGO DE DEPURACIÓN ----
    
    try {
      final response = await _dio.post(
        ApiEndpoints.clients,
        data: payload, // Usamos el payload que imprimimos
      );
      print('Respuesta del servidor exitosa.');
      return ClientModel.fromJson(response.data);
    } on DioException catch (e) {
      // ---- INICIO DE CÓDIGO DE DEPURACIÓN ----
      print('!!!!!! ERROR DE DIO CAPTURADO !!!!!!');
      print('Tipo de error: ${e.type}');
      print('Mensaje de error: ${e.message}');
      print('Respuesta completa del error: ${e.response}');
      print('Datos de la respuesta: ${e.response?.data}');
      print('Stack trace: ${e.stackTrace}');
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      // ---- FIN DE CÓDIGO DE DEPURACIÓN ----
      throw ServerFailure.fromDioException(e);
    }
  }


  @override
  Future<ClientModel> updateClient(String clientId, Map<String, dynamic> allClientData) async {
    try {
      // Igual que en addClient, separamos los campos
      final (fields, customFieldsData) = _separateFields(allClientData);

      final response = await _dio.put(
        ApiEndpoints.clientById(clientId),
        data: {
          'fields': fields, 
          'customFieldsData': customFieldsData
        },
      );
      return ClientModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerFailure.fromDioException(e);
    }
  }

  @override
  Future<void> deleteClient(String clientId) async {
    try {
      await _dio.delete(ApiEndpoints.clientById(clientId));
      // No retorna nada en caso de éxito
    } on DioException catch (e) {
      throw ServerFailure.fromDioException(e);
    }
  }
}