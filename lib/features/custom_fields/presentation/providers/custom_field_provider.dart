// lib/features/custom_fields/presentation/providers/custom_field_provider.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_crm_app/core/network/dio_client.dart';
import 'package:flutter_crm_app/features/custom_fields/data/data_sources/custom_field_remote_data_source.dart';
import 'package:flutter_crm_app/features/custom_fields/data/models/custom_field_model.dart';
import 'package:flutter_crm_app/features/custom_fields/data/repositories/custom_field_repository_impl.dart';
import 'package:flutter_crm_app/features/custom_fields/domain/repositories/custom_field_repository.dart';

// 1. STATE
enum CustomFieldStatus { initial, loading, loaded, error, submitting }

class CustomFieldState extends Equatable {
  final CustomFieldStatus status;
  final List<CustomFieldModel> fields;
  final String? errorMessage;

  const CustomFieldState({
    this.status = CustomFieldStatus.initial,
    this.fields = const [],
    this.errorMessage,
  });

  CustomFieldState copyWith({
    CustomFieldStatus? status,
    List<CustomFieldModel>? fields,
    String? errorMessage,
  }) {
    return CustomFieldState(
      status: status ?? this.status,
      fields: fields ?? this.fields,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, fields, errorMessage];
}


// 2. DEPENDENCY INJECTION
final customFieldRemoteDataSourceProvider = Provider<CustomFieldRemoteDataSource>((ref) {
  return CustomFieldRemoteDataSourceImpl(ref.read(dioProvider));
});

final customFieldRepositoryProvider = Provider<CustomFieldRepository>((ref) {
  return CustomFieldRepositoryImpl(ref.read(customFieldRemoteDataSourceProvider));
});


// 3. NOTIFIER
final customFieldNotifierProvider = StateNotifierProvider<CustomFieldNotifier, CustomFieldState>((ref) {
  return CustomFieldNotifier(ref.read(customFieldRepositoryProvider));
});

class CustomFieldNotifier extends StateNotifier<CustomFieldState> {
  final CustomFieldRepository _repository;
  CustomFieldNotifier(this._repository) : super(const CustomFieldState());

  Future<void> getCustomFields() async {
    state = state.copyWith(status: CustomFieldStatus.loading);
    final result = await _repository.getCustomFields();
    result.fold(
      (failure) => state = state.copyWith(status: CustomFieldStatus.error, errorMessage: failure.message),
      (fields) => state = state.copyWith(status: CustomFieldStatus.loaded, fields: fields),
    );
  }

  Future<bool> createCustomField(String name) async {
    state = state.copyWith(status: CustomFieldStatus.submitting);
    final result = await _repository.createCustomField(name);
    return result.fold(
      (failure) {
        state = state.copyWith(status: CustomFieldStatus.error, errorMessage: failure.message);
        return false;
      },
      (newField) {
        state = state.copyWith(
          status: CustomFieldStatus.loaded,
          fields: [...state.fields, newField], // Añadir el nuevo campo a la lista
        );
        return true;
      },
    );
  }

  Future<bool> deleteCustomField(String id) async {
    state = state.copyWith(status: CustomFieldStatus.submitting);
    final result = await _repository.deleteCustomField(id);
    return result.fold(
      (failure) {
        state = state.copyWith(status: CustomFieldStatus.error, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          status: CustomFieldStatus.loaded,
          fields: state.fields.where((field) => field.id != id).toList(), // Quitar campo de la lista
        );
        return true;
      },
    );
  }
}