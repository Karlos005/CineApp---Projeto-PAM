import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/session_entity.dart';

/// Contrato abstrato do repositório de sessões.
abstract class SessionsRepository {
  Future<Either<Failure, List<SessionEntity>>> getSessionsForMovie(
      int movieId);
}