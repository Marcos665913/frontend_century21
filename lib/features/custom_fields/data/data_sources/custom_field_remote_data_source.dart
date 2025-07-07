// lib/features/custom_fields/data/data_sources/custom_field_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:flutter_crm_app/core/constants/api_endpoints.dart';
import 'package:flutter_crm_app/core/utils/failure.dart';
import 'package:flutter_crm_app/features/custom_fields/data/models/custom_field_model.dart';

abstract class CustomFieldRemoteDataSource {
  Future<List<CustomFieldModel>> getCustomFields();
  Future<CustomFieldModel> createCustomField(String name);
  Future<void> deleteCustomField(String id);
}

class CustomFieldRemoteDataSourceImpl implements CustomFieldRemoteDataSource {
  final Dio _dio;
  CustomFieldRemoteDataSourceImpl(this._dio);

  @override
  Future<List<CustomFieldModel>> getCustomFields() async {
    try {
      final response = await _dio.get(ApiEndpoints.customFields);
      final fields = (response.data as List)
          .map((fieldJson) => CustomFieldModel.fromJson(fieldJson))
          .toList();
      return fields;
    } on DioException catch (e) {
      throw ServerFailure.fromDioException(e);
    }
  }

  @override
  Future<CustomFieldModel> createCustomField(String name) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.customFields,
        data: {'name': name},
      );
      return CustomFieldModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerFailure.fromDioException(e);
    }
  }

  @override
  Future<void> deleteCustomField(String id) async {
    try {
      await _dio.delete(ApiEndpoints.customFieldById(id));
    } on DioException catch (e) {
      throw ServerFailure.fromDioException(e);
    }
  }
}