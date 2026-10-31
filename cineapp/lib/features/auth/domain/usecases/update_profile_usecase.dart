import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileParams extends Equatable {
  final String name;
  final String? phoneNumber;

  const UpdateProfileParams({
    required this.name,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [name, phoneNumber];
}

class UpdateProfileUseCase implements UseCase<UserEntity, UpdateProfileParams> {
  final AuthRepository repository;
  const UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) {
    return repository.updateProfile(
      name: params.name,
      phoneNumber: params.phoneNumber,
    );
  }
}
