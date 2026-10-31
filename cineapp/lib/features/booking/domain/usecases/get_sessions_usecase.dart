import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/session_entity.dart';
import '../repositories/sessions_repository.dart';

/// Obtém as sessões disponíveis para um dado filme.
/// [params] = movieId (int).
class GetSessionsUseCase implements UseCase<List<SessionEntity>, int> {
  final SessionsRepository repository;
  const GetSessionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<SessionEntity>>> call(int movieId) {
    return repository.getSessionsForMovie(movieId);
  }
}