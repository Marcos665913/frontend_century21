// lib/features/custom_fields/data/repositories/custom_field_repository_impl.dart
import 'package:flutter_crm_app/core/utils/failure.dart';
import 'package:flutter_crm_app/features/custom_fields/data/data_sources/custom_field_remote_data_source.dart';
import 'package:flutter_crm_app/features/custom_fields/data/models/custom_field_model.dart';
import 'package:flutter_crm_app/features/custom_fields/domain/repositories/custom_field_repository.dart';
import 'package:fpdart/fpdart.dart';

class CustomFieldRepositoryImpl implements CustomFieldRepository {
  final CustomFieldRemoteDataSource _dataSource;
  CustomFieldRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, CustomFieldModel>> createCustomField(String name) async {
    try {
      final newField = await _dataSource.createCustomField(name);
      return right(newField);
    } on ServerFailure catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCustomField(String id) async {
    try {
      await _dataSource.deleteCustomField(id);
      return right(unit);
    } on ServerFailure catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<Failure, List<CustomFieldModel>>> getCustomFields() async {
    try {
      final fields = await _dataSource.getCustomFields();
      return right(fields);
    } on ServerFailure catch (e) {
      return left(e);
    }
  }
}