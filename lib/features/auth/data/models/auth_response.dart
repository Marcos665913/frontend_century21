// lib/features/auth/data/models/auth_response.dart
import 'package:equatable/equatable.dart';
// UserModel no es parte directa de AuthResponse según el backend, 
// el token es lo principal. El perfil se obtiene por separado.

class AuthResponse extends Equatable {
  final String token;

  const AuthResponse({required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }

  @override
  List<Object?> get props => [token];
}