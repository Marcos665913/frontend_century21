import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_crm_app/core/common_widgets/error_display_widget.dart';
import 'package:flutter_crm_app/core/common_widgets/loading_indicator.dart';
// import 'package:flutter_crm_app/features/reminders/data/models/reminder_model.dart'; // <-- LÍNEA ELIMINADA
import 'package:flutter_crm_app/features/reminders/presentation/providers/reminder_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ReminderListScreen extends ConsumerStatefulWidget {
  const ReminderListScreen({super.key});

  @override
  ConsumerState<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends ConsumerState<ReminderListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reminderNotifierProvider);
    final query = _searchController.text.toLowerCase();

    final filteredReminders = state.reminders.where((reminder) {
      if (query.isEmpty) return true;
      final messageMatch = reminder.mensaje.toLowerCase().contains(query);
      final clientMatch = reminder.cliente?.nombre.toLowerCase().contains(query) ?? false;
      return messageMatch || clientMatch;
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por mensaje o cliente',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(reminderNotifierProvider.notifier).getReminders(),
              child: Builder(
                builder: (context) {
                  if (state.status == ReminderStatus.loading && state.reminders.isEmpty) {
                    return const LoadingIndicator(message: "Cargando recordatorios...");
                  }
                  if (state.status == ReminderStatus.error && state.reminders.isEmpty) {
                    return ErrorDisplayWidget(
                      errorMessage: state.errorMessage!,
                      onRetry: () => ref.read(reminderNotifierProvider.notifier).getReminders(),
                    );
                  }
                  if (filteredReminders.isEmpty) {
                    return LayoutBuilder(builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: Center(child: Text(query.isEmpty ? 'No hay recordatorios.' : 'No se encontraron resultados.')),
                        ),
                      );
                    });
                  }
                  
                  return ListView.builder(
                    itemCount: filteredReminders.length,
                    itemBuilder: (context, index) {
                      final reminder = filteredReminders[index];
                      final isOverdue = reminder.fecha.isBefore(DateTime.now());
                      final cardBorderColor = isOverdue ? Colors.red.shade300 : Colors.transparent;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: cardBorderColor, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.alarm, color: isOverdue ? Colors.red : Theme.of(context).primaryColor),
                          title: Text(reminder.mensaje, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Para: ${reminder.cliente?.nombre ?? "General"}'),
                              Text('Fecha: ${DateFormat.yMMMMd('es_ES').add_jm().format(reminder.fecha.toLocal())}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirmar'),
                                  content: const Text('¿Seguro que quieres eliminar este recordatorio?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
                                    TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await ref.read(reminderNotifierProvider.notifier).deleteReminder(reminder.id);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/reminders/new'),
        child: const Icon(Icons.add_alarm),
      ),
    );
  }
}
