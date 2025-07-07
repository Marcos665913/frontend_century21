// lib/features/custom_fields/data/models/custom_field_model.dart
import 'package:equatable/equatable.dart';

class CustomFieldModel extends Equatable {
  final String id;
  final String name; // Nombre para mostrar en la UI (ej. "Notas Adicionales")
  final String key;  // Clave interna para la DB (ej. "notasadicionales")
  final String type; // Siempre "string" por ahora

  const CustomFieldModel({
    required this.id,
    required this.name,
    required this.key,
    required this.type,
  });

  factory CustomFieldModel.fromJson(Map<String, dynamic> json) {
    return CustomFieldModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      key: json['key'] as String,
      type: json['type'] as String? ?? 'string', // Por si acaso
    );
  }

  @override
  List<Object?> get props => [id, name, key, type];
}