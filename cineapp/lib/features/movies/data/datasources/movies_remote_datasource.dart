import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/movie_model.dart';

abstract class MoviesRemoteDataSource {
  Future<List<MovieModel>> getNowPlaying();
  Future<List<MovieModel>> getPopularMovies();
  Future<List<MovieModel>> searchMovies(String query);
  Future<MovieModel> getMovieDetail(int id);
}

class MoviesRemoteDataSourceImpl implements MoviesRemoteDataSource {
  final Dio dio;
  MoviesRemoteDataSourceImpl(this.dio);

  @override
  Future<List<MovieModel>> getNowPlaying() async {
    try {
      final response = await dio.get('/movie/now_playing', queryParameters: {
        'language': ApiConstants.language,
        'region': 'PT',
      });
      final results = response.data['results'] as List;
      return results.map((e) => MovieModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Erro ao carregar filmes em cartaz');
    }
  }

  @override
  Future<List<MovieModel>> getPopularMovies() async {
    try {
      final response = await dio.get('/movie/popular', queryParameters: {
        'language': ApiConstants.language,
      });
      final results = response.data['results'] as List;
      return results.map((e) => MovieModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Erro ao carregar populares');
    }
  }

  @override
  Future<List<MovieModel>> searchMovies(String query) async {
    try {
      final response = await dio.get('/search/movie', queryParameters: {
        'query': query,
        'language': ApiConstants.language,
      });
      final results = response.data['results'] as List;
      return results.map((e) => MovieModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Erro na pesquisa');
    }
  }

  @override
  Future<MovieModel> getMovieDetail(int id) async {
    try {
      final response = await dio.get('/movie/$id', queryParameters: {
        'language': ApiConstants.language,
        'append_to_response': 'release_dates',
      });
      return MovieModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Filme não encontrado');
    }
  }
}