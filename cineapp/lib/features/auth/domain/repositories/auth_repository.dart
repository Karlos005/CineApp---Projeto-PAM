import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn(String email, String password);
  Future<Either<Failure, UserEntity>> signUp(String email, String password, String name);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> sendPasswordReset(String email);
  Future<Either<Failure, UserEntity>> updateProfile(
      {required String name, String? phoneNumber});
  Future<Either<Failure, UserEntity>> uploadProfilePhoto(Uint8List bytes);
  Stream<UserEntity?> get authStateChanges;
}