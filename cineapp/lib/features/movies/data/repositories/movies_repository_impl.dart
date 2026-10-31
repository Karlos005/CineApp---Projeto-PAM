import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/repositories/movies_repository.dart';
import '../datasources/movies_remote_datasource.dart';

/// Implementação concreta de [MoviesRepository].
/// Traduz ServerException / NetworkException → Failure do domínio.
class MoviesRepositoryImpl implements MoviesRepository {
  final MoviesRemoteDataSource remoteDataSource;

  MoviesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<MovieEntity>>> getNowPlaying() async {
    try {
      final movies = await remoteDataSource.getNowPlaying();
      return Right(movies);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(NetworkFailure(message: _networkMessage(e)));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> getPopularMovies() async {
    try {
      final movies = await remoteDataSource.getPopularMovies();
      return Right(movies);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(NetworkFailure(message: _networkMessage(e)));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> searchMovies(
      String query) async {
    try {
      if (query.trim().isEmpty) return const Right([]);
      final movies = await remoteDataSource.searchMovies(query);
      return Right(movies);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(NetworkFailure(message: _networkMessage(e)));
    }
  }

  @override
  Future<Either<Failure, MovieEntity>> getMovieDetail(int id) async {
    try {
      final movie = await remoteDataSource.getMovieDetail(id);
      return Right(movie);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(NetworkFailure(message: _networkMessage(e)));
    }
  }

  String _networkMessage(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('socketexception') || msg.contains('network')) {
      return 'Sem ligação à internet. Verifica a tua rede.';
    }
    return 'Erro inesperado: $e';
  }
}