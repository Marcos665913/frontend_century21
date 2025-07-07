import 'package:flutter_crm_app/core/utils/failure.dart';
import 'package:flutter_crm_app/features/reminders/data/data_sources/reminder_remote_data_source.dart';
import 'package:flutter_crm_app/features/reminders/data/models/reminder_model.dart';
import 'package:flutter_crm_app/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:fpdart/fpdart.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderRemoteDataSource _dataSource;
  ReminderRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<ReminderModel>>> getReminders() async {
    try {
      return right(await _dataSource.getReminders());
    } on ServerFailure catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<Failure, ReminderModel>> scheduleReminder(Map<String, dynamic> data) async {
    try {
      return right(await _dataSource.scheduleReminder(data));
    } on ServerFailure catch (e) {
      return left(e);
    }
  }
  @override
  Future<Either<Failure, Unit>> deleteReminder(String id) async {
    try {
      await _dataSource.deleteReminder(id);
      return right(unit);
    } on ServerFailure catch (e) {
      return left(e);
    }
  }
  
}
