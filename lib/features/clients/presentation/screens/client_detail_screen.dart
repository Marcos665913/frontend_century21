// lib/features/clients/presentation/screens/client_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_crm_app/core/common_widgets/error_display_widget.dart';
import 'package:flutter_crm_app/core/common_widgets/role_specific_widget.dart';
import 'package:flutter_crm_app/core/constants/enums.dart';
import 'package:flutter_crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_crm_app/features/clients/data/models/client_model.dart';
import 'package:flutter_crm_app/features/clients/presentation/providers/client_provider.dart';
import 'package:flutter_crm_app/features/custom_fields/presentation/providers/custom_field_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter_crm_app/core/network/dio_client.dart'; // Importar AppLogger

class ClientDetailScreen extends ConsumerWidget {
  final String clientId;
  const ClientDetailScreen({super.key, required this.clientId});

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que deseas eliminar este cliente? Esta acción no se puede deshacer.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final success = await ref.read(clientNotifierProvider.notifier).deleteClient(clientId);
                if (success) {
                  Fluttertoast.showToast(msg: 'Cliente eliminado correctamente');
                  if (context.mounted) {
                    AppLogger.log('ClientDetailScreen: Cliente eliminado, realizando pop.');
                    context.pop(); // Pop de ClientDetailScreen para volver a ClientListScreen
                  }
                } else {
                   Fluttertoast.showToast(
                    msg: ref.read(clientNotifierProvider).errorMessage ?? 'Error al eliminar',
                    backgroundColor: Colors.red
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientState = ref.watch(clientNotifierProvider);
    final currentUser = ref.watch(authNotifierProvider).user;
    
    ClientModel? client;
    try {
      client = clientState.clients.firstWhere((c) => c.id == clientId);
      AppLogger.log('ClientDetailScreen: Cliente cargado para detalle: ${client.nombre}');
    } catch (e) {
      client = null;
      AppLogger.error('ClientDetailScreen: Error al encontrar cliente en estado: $e');
    }

    if (client == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error'), leading: const BackButton()),
        body: const ErrorDisplayWidget(
          errorMessage: 'No se pudo encontrar el cliente. Es posible que haya sido eliminado. Vuelve a la lista.',
        ),
      );
    }
    
    bool canEditClient = false;
    if (currentUser?.userRoleEnum == UserRole.master) {
      canEditClient = true;
    }
    else if (currentUser?.userRoleEnum == UserRole.privileged && client.createdBy?.userRoleEnum != UserRole.master) {
      canEditClient = true;
    }
    else if (currentUser?.userRoleEnum == UserRole.normal && client.createdBy?.id == currentUser?.id) {
       canEditClient = true;
    }
    AppLogger.log('ClientDetailScreen: build llamado. Cliente: ${client.nombre}, canEdit: $canEditClient');

    return Scaffold(
      appBar: AppBar(
        title: Text(client.nombre),
        leading: const BackButton(),
        actions: [
          if (canEditClient)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                AppLogger.log('ClientDetailScreen: Edit tap. Navegando a /clients/$clientId/edit (push).');
                context.push('/clients/$clientId/edit'); // <-- CAMBIO CLAVE: Usar push
              },
            ),
          RoleSpecificWidget(
            allowedRoles: const [UserRole.master],
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmationDialog(context, ref),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildDetailCard(context, client),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_alert),
                label: const Text('Programar Recordatorio'),
                onPressed: () {
                  AppLogger.log('ClientDetailScreen: Programar Recordatorio tap. Navegando a /reminders/new (push).');
                  context.push('/reminders/new?clientId=$clientId'); // <-- CAMBIO CLAVE: Usar push
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, ClientModel client) {
    // Se definen los formateadores aquí para que tengan el alcance correcto.
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'es_MX');
    final dateTimeFormat = DateFormat.yMMMMd('es_ES').add_jm();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(context, 'Nombre', client.nombre, icon: Icons.person),
            _buildDetailRow(context, 'Teléfono', client.telefono, icon: Icons.phone),
            _buildDetailRow(context, 'Correo', client.correo, icon: Icons.email),
            _buildDetailRow(context, 'Origen', client.origen?.displayValue, icon: Icons.explore),
            _buildDetailRow(context, 'Asesor Asignado', client.createdBy?.name, icon: Icons.support_agent),
            
            const Divider(height: 24, thickness: 1),

            _buildDetailRow(context, 'Asunto', client.asunto?.displayValue, icon: Icons.business_center),
            _buildDetailRow(context, 'Tipo de Inmueble', client.tipoInmueble?.displayValue, icon: Icons.home_work),
            _buildDetailRow(context, 'Presupuesto', currencyFormat.format(client.presupuesto), icon: Icons.attach_money),
            _buildDetailRow(context, 'Tipo de Pago', client.tipoPago?.displayValue, icon: Icons.payment),
            _buildDetailRow(context, 'Zona de Interés', client.zona, icon: Icons.map),
            
            const Divider(height: 24, thickness: 1),

            _buildDetailRow(context, 'Estatus', client.estatus?.displayValue, icon: Icons.flag),
            if (client.fechaContacto != null)
              _buildDetailRow(context, 'Fecha de Contacto', dateTimeFormat.format(client.fechaContacto!.toLocal()), icon: Icons.calendar_today),
            if (client.fechaAsignacion != null)
              _buildDetailRow(context, 'Fecha de Asignación', dateTimeFormat.format(client.fechaAsignacion!.toLocal()), icon: Icons.assignment_ind),
            _buildDetailRow(context, 'Seguimiento', client.seguimiento, icon: Icons.track_changes),
            _buildDetailRow(context, 'Especificaciones', client.especificaciones, icon: Icons.notes),
            _buildDetailRow(context, 'Observaciones', client.observaciones, icon: Icons.comment),
            
            Consumer(builder: (context, ref, _) {
              final customFieldDefs = ref.watch(customFieldNotifierProvider).fields;
              if (client.customFieldsData.isEmpty || customFieldDefs.isEmpty) {
                return const SizedBox.shrink();
              }
              final defsMap = {for (var e in customFieldDefs) e.key: e.name};
              List<Widget> customFieldWidgets = [];
              client.customFieldsData.forEach((key, value) {
                if (value != null && value.toString().isNotEmpty && defsMap.containsKey(key)) {
                  customFieldWidgets.add(
                    _buildDetailRow(context, defsMap[key]!, value.toString(), icon: Icons.add_circle_outline)
                  );
                }
              });
              if (customFieldWidgets.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 20),
                  Text('Información Adicional', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...customFieldWidgets,
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String? value, {IconData? icon}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Theme.of(context).primaryColor, size: 20),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}