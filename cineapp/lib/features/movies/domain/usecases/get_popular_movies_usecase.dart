import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/movie_entity.dart';
import '../repositories/movies_repository.dart';

class GetPopularMoviesUseCase implements UseCase<List<MovieEntity>, NoParams> {
  final MoviesRepository repository;
  const GetPopularMoviesUseCase(this.repository);

  @override
  Future<Either<Failure, List<MovieEntity>>> call(NoParams params) {
    return repository.getPopularMovies();
  }
}