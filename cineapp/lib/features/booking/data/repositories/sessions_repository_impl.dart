import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/sessions_repository.dart';
import '../datasources/sessions_datasource.dart';

class SessionsRepositoryImpl implements SessionsRepository {
  final SessionsDataSource dataSource;

  SessionsRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<SessionEntity>>> getSessionsForMovie(
      int movieId) async {
    try {
      final sessions = await dataSource.getSessionsForMovie(movieId);
      return Right(sessions);
    } catch (e) {
      return Left(ServerFailure(
          message: 'Não foi possível carregar as sessões: $e'));
    }
  }
}