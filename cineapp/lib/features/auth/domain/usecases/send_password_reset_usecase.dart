import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Envia email de recuperação de password — ecrã 12.
class SendPasswordResetUseCase implements UseCase<void, String> {
  final AuthRepository repository;
  const SendPasswordResetUseCase(this.repository);

  /// [params] é o email do utilizador
  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.sendPasswordReset(params);
  }
}