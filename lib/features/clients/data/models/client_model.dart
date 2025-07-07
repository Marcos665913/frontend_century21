import 'package:equatable/equatable.dart';
import 'package:flutter_crm_app/core/constants/enums.dart';
import 'package:flutter_crm_app/features/auth/data/models/user_model.dart';

class ClientModel extends Equatable {
  final String id;
  final Map<String, dynamic> fields;
  final Map<String, dynamic> customFieldsData;
  final UserModel? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ClientModel({
    required this.id,
    required this.fields,
    required this.customFieldsData,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  // --- GETTERS ACTUALIZADOS Y NUEVOS ---
  DateTime? get fechaContacto => fields['fechaContacto'] != null ? DateTime.tryParse(fields['fechaContacto']) : null;
  DateTime? get fechaAsignacion => fields['fechaAsignacion'] != null ? DateTime.tryParse(fields['fechaAsignacion']) : null;
  
  String get nombre => fields['nombre']?.toString() ?? '';
  String get telefono => fields['telefono']?.toString() ?? '';
  String get correo => fields['correo']?.toString() ?? '';
  
  AsuntoInmobiliario? get asunto => enumFromString(AsuntoInmobiliario.values, fields['asunto']?.toString());
  TipoInmueble? get tipoInmueble => enumFromString(TipoInmueble.values, fields['tipoInmueble']?.toString());
  OrigenCliente? get origen => enumFromString(OrigenCliente.values, fields['origen']?.toString());
  EstatusCliente? get estatus => enumFromString(EstatusCliente.values, fields['estatus']?.toString());
  
  String get seguimiento => fields['seguimiento']?.toString() ?? '';
  
  double get presupuesto => (fields['presupuesto'] as num?)?.toDouble() ?? 0.0;
  TipoPago? get tipoPago => enumFromString(TipoPago.values, fields['tipoPago']?.toString());
  String get zona => fields['zona']?.toString() ?? '';
  
  String get especificaciones => fields['especificaciones']?.toString() ?? '';
  String get observaciones => fields['observaciones']?.toString() ?? '';

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['_id'] as String,
      fields: json['fields'] as Map<String, dynamic>? ?? {},
      customFieldsData: json['customFieldsData'] as Map<String, dynamic>? ?? {},
      createdBy: json['createdBy'] != null ? UserModel.fromJson(json['createdBy']) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  @override
  List<Object?> get props => [id, fields, customFieldsData, createdBy, createdAt, updatedAt];
}
