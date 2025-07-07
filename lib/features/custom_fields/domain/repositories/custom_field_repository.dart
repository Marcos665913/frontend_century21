// lib/features/custom_fields/domain/repositories/custom_field_repository.dart
import 'package:flutter_crm_app/core/utils/failure.dart';
import 'package:flutter_crm_app/features/custom_fields/data/models/custom_field_model.dart';
import 'package:fpdart/fpdart.dart';

abstract class CustomFieldRepository {
  Future<Either<Failure, List<CustomFieldModel>>> getCustomFields();
  Future<Either<Failure, CustomFieldModel>> createCustomField(String name);
  Future<Either<Failure, Unit>> deleteCustomField(String id);
}