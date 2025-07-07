// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:flutter_crm_app/core/utils/failure.dart';
import 'package:flutter_crm_app/features/auth/data/models/user_model.dart';
import 'package:fpdart/fpdart.dart'; // Para Either

// fpdart es una alternativa a dartz para manejo funcional de errores (Either)
// Puedes añadirlo a tu pubspec.yaml: fpdart: ^1.1.0

abstract class AuthRepository {
  Future<Either<Failure, Unit>> login(String email, String password);
  Future<Either<Failure, Unit>> register(String name, String email, String password, String role);
  Future<Either<Failure, UserModel>> getUserProfile();
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, UserModel?>> checkAuthStatus(); // Para verificar si ya hay sesión
}