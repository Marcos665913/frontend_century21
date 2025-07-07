import 'package:dio/dio.dart';
import 'package:flutter_crm_app/core/constants/api_endpoints.dart';
import 'package:flutter_crm_app/core/utils/failure.dart';
import 'package:flutter_crm_app/features/reminders/data/models/reminder_model.dart';

abstract class ReminderRemoteDataSource {
  Future<List<ReminderModel>> getReminders();
  Future<ReminderModel> scheduleReminder(Map<String, dynamic> data);
  Future<void> deleteReminder(String id); // <-- CORRECCIÓN: AÑADIDO AQUÍ
}

class ReminderRemoteDataSourceImpl implements ReminderRemoteDataSource {
  final Dio _dio;
  ReminderRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ReminderModel>> getReminders() async {
    try {
      final response = await _dio.get(ApiEndpoints.reminders);
      return (response.data as List).map((e) => ReminderModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ServerFailure.fromDioException(e);
    }
  }

  @override
  Future<ReminderModel> scheduleReminder(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiEndpoints.reminders, data: data);
      return ReminderModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerFailure.fromDioException(e);
    }
  }
  @override
  Future<void> deleteReminder(String id) async {
    try {
      await _dio.delete(ApiEndpoints.reminderById(id));
    } on DioException catch (e) {
      throw ServerFailure.fromDioException(e);
    }
  }

}
