import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UploadProfilePhotoUseCase implements UseCase<UserEntity, Uint8List> {
  final AuthRepository repository;
  const UploadProfilePhotoUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(Uint8List params) {
    return repository.uploadProfilePhoto(params);
  }
}
