// C:\projectsFlutter\flutter_crm_app\lib\features\reminders\data\models\reminder_model.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_crm_app/features/clients/data/models/client_model.dart';

class ReminderModel extends Equatable {
  final String id;
  final String mensaje;
  final DateTime fecha;
  final String status;
  final ClientModel? cliente;

  const ReminderModel({
    required this.id,
    required this.mensaje,
    required this.fecha,
    required this.status,
    this.cliente,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    // Manejo del campo 'cliente':
    // Puede ser un String (ID) o un Map (objeto populado)
    ClientModel? parsedClient;
    if (json['cliente'] != null) {
      if (json['cliente'] is Map<String, dynamic>) {
        // Si es un mapa, significa que el cliente está populado
        parsedClient = ClientModel.fromJson(json['cliente'] as Map<String, dynamic>);
      } else if (json['cliente'] is String) {
        // Si es un string, significa que es solo el ID.
        // En este caso, no podemos construir un ClientModel completo,
        // así que lo dejamos como null o creamos un ClientModel mínimo con solo el ID si fuera necesario.
        // Para este caso, lo dejaremos como null para evitar errores.
        parsedClient = null; // O podrías crear ClientModel(id: json['cliente'] as String) si ClientModel lo soporta.
      }
    }

    return ReminderModel(
      id: json['_id'] as String? ?? '',
      mensaje: json['mensaje'] as String? ?? 'Sin mensaje',
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha'] as String) : DateTime.now(),
      status: json['status'] as String? ?? 'pending',
      cliente: parsedClient, // Usamos el cliente parseado
    );
  }

  @override
  List<Object?> get props => [id, mensaje, fecha, status, cliente];
}