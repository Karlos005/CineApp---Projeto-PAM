import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/movie_entity.dart';

abstract class MoviesRepository {
  Future<Either<Failure, List<MovieEntity>>> getNowPlaying();
  Future<Either<Failure, List<MovieEntity>>> getPopularMovies();
  Future<Either<Failure, List<MovieEntity>>> searchMovies(String query);
  Future<Either<Failure, MovieEntity>> getMovieDetail(int id);
}