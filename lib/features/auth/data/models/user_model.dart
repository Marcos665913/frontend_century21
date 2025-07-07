import 'package:equatable/equatable.dart';
import 'package:flutter_crm_app/core/constants/enums.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  // Getter para saber si el usuario está activo.
  bool get isActive => status == 'active';
  
  // Getter para convertir el rol de string a enum.
  UserRole get userRoleEnum => userRoleFromString(role);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Usuario Desconocido',
      email: json['email'] as String? ?? 'sin-email@registrado.com',
      role: json['role'] as String? ?? 'normal',
      status: json['status'] as String? ?? 'inactive', // Default a inactivo por seguridad
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }
  
  @override
  List<Object?> get props => [id, name, email, role, status, createdAt, updatedAt];
}
