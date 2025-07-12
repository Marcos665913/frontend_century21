// C:\projectsFlutter\flutter_crm_app\lib\features\reminders\data\data_sources\reminder_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:flutter_crm_app/core/constants/api_endpoints.dart';
import 'package:flutter_crm_app/core/utils/failure.dart';
import 'package:flutter_crm_app/features/reminders/data/models/reminder_model.dart';
import 'package:flutter_crm_app/core/network/dio_client.dart'; // Importar AppLogger

abstract class ReminderRemoteDataSource {
  Future<List<ReminderModel>> getReminders();
  Future<ReminderModel> scheduleReminder(Map<String, dynamic> data);
  Future<void> deleteReminder(String id); // Añadido
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
      AppLogger.log('ReminderRemoteDataSourceImpl: Enviando recordatorio al backend.');
      final response = await _dio.post(ApiEndpoints.reminders, data: data);
      AppLogger.log('ReminderRemoteDataSourceImpl: Respuesta del backend recibida. Status: ${response.statusCode}');
      AppLogger.log('ReminderRemoteDataSourceImpl: Datos de respuesta: ${response.data}');
      return ReminderModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error('ReminderRemoteDataSourceImpl: DioError al programar recordatorio.');
      AppLogger.error('ReminderRemoteDataSourceImpl: Error response: ${e.response?.data}');
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
