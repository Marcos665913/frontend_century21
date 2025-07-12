// C:\projectsFlutter\flutter_crm_app\lib\features\reminders\presentation\providers\reminder_provider.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_crm_app/core/network/dio_client.dart'; // Importar AppLogger
import 'package:flutter_crm_app/features/reminders/data/data_sources/reminder_remote_data_source.dart';
import 'package:flutter_crm_app/features/reminders/data/models/reminder_model.dart';
import 'package:flutter_crm_app/features/reminders/data/repositories/reminder_repository_impl.dart';
import 'package:flutter_crm_app/features/reminders/domain/repositories/reminder_repository.dart';

// 1. STATE
enum ReminderStatus { initial, loading, loaded, error, submitting }

class ReminderState extends Equatable {
  final ReminderStatus status;
  final List<ReminderModel> reminders;
  final String? errorMessage;

  const ReminderState({
    this.status = ReminderStatus.initial,
    this.reminders = const [],
    this.errorMessage,
  });

  ReminderState copyWith({
    ReminderStatus? status,
    List<ReminderModel>? reminders,
    String? errorMessage,
  }) {
    return ReminderState(
      status: status ?? this.status,
      reminders: reminders ?? this.reminders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, reminders, errorMessage];
}

// 2. DEPENDENCY INJECTION
final reminderRemoteDataSourceProvider = Provider<ReminderRemoteDataSource>((ref) {
  return ReminderRemoteDataSourceImpl(ref.read(dioProvider));
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepositoryImpl(ref.read(reminderRemoteDataSourceProvider));
});

// 3. NOTIFIER
final reminderNotifierProvider = StateNotifierProvider<ReminderNotifier, ReminderState>((ref) {
  return ReminderNotifier(ref.read(reminderRepositoryProvider));
});

class ReminderNotifier extends StateNotifier<ReminderState> {
  final ReminderRepository _repository;
  ReminderNotifier(this._repository) : super(const ReminderState()) {
    getReminders();
  }

  Future<void> getReminders() async {
    state = state.copyWith(status: ReminderStatus.loading);
    final result = await _repository.getReminders();
    result.fold(
      (failure) => state = state.copyWith(status: ReminderStatus.error, errorMessage: failure.message),
      (reminders) {
        reminders.sort((a, b) => a.fecha.compareTo(b.fecha));
        state = state.copyWith(status: ReminderStatus.loaded, reminders: reminders);
      },
    );
  }

  Future<bool> scheduleReminder(Map<String, dynamic> data) async {
    // Nuevos Logs en scheduleReminder
    AppLogger.log('ReminderNotifier: scheduleReminder iniciado. Estado actual: ${state.status}');
    state = state.copyWith(status: ReminderStatus.submitting);
    final result = await _repository.scheduleReminder(data);
    return result.fold(
      (failure) {
        AppLogger.error('ReminderNotifier: Fallo al programar recordatorio. Error: ${failure.message}');
        state = state.copyWith(status: ReminderStatus.error, errorMessage: failure.message);
        return false;
      },
      (newReminder) {
        final updatedList = List<ReminderModel>.from(state.reminders)
          ..add(newReminder);
        updatedList.sort((a, b) => a.fecha.compareTo(b.fecha));
        
        state = state.copyWith(status: ReminderStatus.loaded, reminders: updatedList);
        AppLogger.log('ReminderNotifier: Recordatorio programado y lista actualizada. ID: ${newReminder.id}');
        return true;
      },
    );
  }

  Future<bool> deleteReminder(String id) async {
    state = state.copyWith(status: ReminderStatus.submitting);
    final result = await _repository.deleteReminder(id);
    return result.fold(
      (failure) {
        state = state.copyWith(status: ReminderStatus.error, errorMessage: failure.message);
        return false;
      },
      (_) {
        final updatedList = state.reminders.where((r) => r.id != id).toList();
        state = state.copyWith(status: ReminderStatus.loaded, reminders: updatedList);
        return true;
      },
    );
  }
}
