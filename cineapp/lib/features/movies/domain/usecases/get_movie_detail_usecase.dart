import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/movie_entity.dart';
import '../repositories/movies_repository.dart';

/// Obtém os detalhes completos de um filme pelo seu ID TMDB.
/// [params] = movieId (int).
class GetMovieDetailUseCase implements UseCase<MovieEntity, int> {
  final MoviesRepository repository;
  const GetMovieDetailUseCase(this.repository);

  @override
  Future<Either<Failure, MovieEntity>> call(int movieId) {
    return repository.getMovieDetail(movieId);
  }
}