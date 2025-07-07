// lib/features/clients/presentation/widgets/client_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_crm_app/features/clients/data/models/client_model.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_crm_app/core/constants/enums.dart'; // ¡Importación añadida para EstatusCliente!

class ClientListItem extends StatelessWidget {
  final ClientModel client;
  const ClientListItem({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navegar a la pantalla de detalles del cliente
          context.go('/clients/${client.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      client.nombre,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(
                    label: Text(
                      client.estatus?.displayValue ?? 'N/A',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    backgroundColor: _getStatusColor(client.estatus),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.business_center, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text('Asunto: ${client.asunto?.displayValue ?? 'No especificado'}', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(client.telefono, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              if (client.createdBy?.name != null) ...[
                const SizedBox(height: 8),
                const Divider(),
                Row(
                  children: [
                    Icon(Icons.person_pin_circle_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text('Asesor: ${client.createdBy!.name}', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- CORRECCIÓN: Se completan todos los casos de EstatusCliente ---
  Color _getStatusColor(EstatusCliente? status) {
    switch (status) {
      case EstatusCliente.iniciado:
        return Colors.blue;
      case EstatusCliente.enCurso:
        return Colors.orange;
      case EstatusCliente.completado:
        return Colors.green;
      case EstatusCliente.standby:
        return Colors.grey;
      case EstatusCliente.cancelado: // Caso corregido
        return Colors.red;
      case EstatusCliente.citado: // Nuevo caso
        return Colors.lightBlueAccent; // Un color distintivo para "citado"
      case EstatusCliente.rechazado: // Nuevo caso
        return Colors.deepOrange; // Un color distintivo para "rechazado"
      case EstatusCliente.sinComenzar: // Nuevo caso
        return Colors.teal; // Un color distintivo para "sin comenzar"
      case EstatusCliente.sinRespuesta: // Nuevo caso
        return Colors.brown; // Un color distintivo para "sin respuesta"
      default:
        return Colors.black45; // Color por defecto si el estado es nulo o no reconocido
    }
  }
}