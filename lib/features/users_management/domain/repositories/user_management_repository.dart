import 'package:flutter_crm_app/core/utils/failure.dart';
import 'package:flutter_crm_app/features/auth/data/models/user_model.dart';
import 'package:fpdart/fpdart.dart';

abstract class UserManagementRepository {
  Future<Either<Failure, List<UserModel>>> getAllUsers();
  Future<Either<Failure, Unit>> assignRole(String userId, String role);
  // --- LÍNEAS AÑADIDAS ---
  Future<Either<Failure, Unit>> deactivateUser(String userId);
  Future<Either<Failure, Unit>> reactivateUser(String userId);
}
