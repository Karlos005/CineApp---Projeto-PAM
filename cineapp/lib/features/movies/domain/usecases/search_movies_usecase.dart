import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/movie_entity.dart';
import '../repositories/movies_repository.dart';

class SearchMoviesUseCase implements UseCase<List<MovieEntity>, String> {
  final MoviesRepository repository;
  const SearchMoviesUseCase(this.repository);

  @override
  Future<Either<Failure, List<MovieEntity>>> call(String query) {
    return repository.searchMovies(query);
  }
}