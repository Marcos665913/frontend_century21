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
    return ReminderModel(
      // --- INICIO DE LA CORRECCIÓN ---
      // Se añade protección contra nulos para todos los campos requeridos
      id: json['_id'] as String? ?? '',
      mensaje: json['mensaje'] as String? ?? 'Sin mensaje',
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha'] as String) : DateTime.now(),
      status: json['status'] as String? ?? 'pending',
      // --- FIN DE LA CORRECCIÓN ---
      cliente: json['cliente'] != null
          ? ClientModel.fromJson(json['cliente'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, mensaje, fecha, status, cliente];
}
