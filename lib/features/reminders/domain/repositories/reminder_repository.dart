// C:\projectsFlutter\flutter_crm_app\lib\features\reminders\domain\repositories\reminder_repository.dart
import 'package:flutter_crm_app/core/utils/failure.dart';
import 'package:flutter_crm_app/features/reminders/data/models/reminder_model.dart';
import 'package:fpdart/fpdart.dart';

abstract class ReminderRepository {
  Future<Either<Failure, List<ReminderModel>>> getReminders();
  Future<Either<Failure, ReminderModel>> scheduleReminder(Map<String, dynamic> data);
  Future<Either<Failure, Unit>> deleteReminder(String id); // Añadido
}
