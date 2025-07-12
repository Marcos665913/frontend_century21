// C:\projectsFlutter\flutter_crm_app\lib\features\reminders\presentation\screens\schedule_reminder_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_crm_app/features/clients/presentation/providers/client_provider.dart';
import 'package:flutter_crm_app/features/reminders/presentation/providers/reminder_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter_crm_app/core/network/dio_client.dart'; // Importar AppLogger

class ScheduleReminderScreen extends ConsumerStatefulWidget {
  final String? clientId;
  const ScheduleReminderScreen({super.key, this.clientId});

  @override
  ConsumerState<ScheduleReminderScreen> createState() => _ScheduleReminderScreenState();
}

class _ScheduleReminderScreenState extends ConsumerState<ScheduleReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedClientId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedClientId = widget.clientId;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
    );
    if (time == null) return;
    
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        Fluttertoast.showToast(msg: 'Por favor, selecciona una fecha y hora.');
        return;
      }

      setState(() { _isLoading = true; });

      final utcDate = _selectedDate!.toUtc();

      final data = {
        'mensaje': _messageController.text.trim(),
        'fecha': utcDate.toIso8601String(), // Enviamos la fecha en formato UTC
        if (_selectedClientId != null) 'cliente': _selectedClientId,
      };

      // Nuevos Logs en _submitForm
      AppLogger.log('ScheduleReminderScreen: _submitForm iniciado.');
      AppLogger.log('ScheduleReminderScreen: Datos a enviar: $data');

      final success = await ref.read(reminderNotifierProvider.notifier).scheduleReminder(data);

      if (mounted) {
        setState(() { _isLoading = false; });
        final errorMessage = ref.read(reminderNotifierProvider).errorMessage;
        Fluttertoast.showToast(
          msg: success ? 'Recordatorio guardado' : (errorMessage ?? 'Error'),
          backgroundColor: success ? Colors.green : Colors.red
        );
        if (success) {
          AppLogger.log('ScheduleReminderScreen: Recordatorio guardado exitosamente. Navegando hacia atrás.');
          context.pop(); 
        } else {
          AppLogger.error('ScheduleReminderScreen: Fallo al guardar recordatorio. Error: $errorMessage');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientNotifierProvider).clients;
    return Scaffold(
      appBar: AppBar(title: const Text('Programar Recordatorio'), leading: const BackButton()),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _selectedClientId,
              decoration: const InputDecoration(labelText: 'Asociar a Cliente (Opcional)', border: OutlineInputBorder()),
              items: clients.map((client) => DropdownMenuItem(value: client.id, child: Text(client.nombre))).toList(),
              onChanged: (value) => setState(() => _selectedClientId = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Mensaje del Recordatorio*', border: OutlineInputBorder()),
              validator: (value) => (value == null || value.isEmpty) ? 'El mensaje es obligatorio' : null,
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8)
              ),
              leading: const Icon(Icons.calendar_today),
              title: Text(_selectedDate == null
                  ? 'Seleccionar fecha y hora*'
                  : DateFormat.yMMMMd('es_ES').add_jm().format(_selectedDate!)),
              trailing: const Icon(Icons.edit),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 24),
            _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('GUARDAR RECORDATORIO'),
                )
          ],
        ),
      ),
    );
  }
}
