import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/movies_remote_datasource.dart';
import '../../data/repositories/movies_repository_impl.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/repositories/movies_repository.dart';
import '../../domain/usecases/get_now_playing_usecase.dart';
import '../../domain/usecases/get_popular_movies_usecase.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Infraestrutura partilhada pela feature movies
// (movie_detail_provider.dart e search_provider.dart importam daqui)
// ─────────────────────────────────────────────────────────────────────────────

/// Cliente HTTP Dio — partilhado com todas as features que usam TMDB
final dioClientProvider = Provider<DioClient>((_) => DioClient());

final moviesRemoteDataSourceProvider =
    Provider<MoviesRemoteDataSource>((ref) {
  return MoviesRemoteDataSourceImpl(ref.watch(dioClientProvider).dio);
});

final moviesRepositoryProvider = Provider<MoviesRepository>((ref) {
  return MoviesRepositoryImpl(
      ref.watch(moviesRemoteDataSourceProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// Use Cases
// ─────────────────────────────────────────────────────────────────────────────

final getNowPlayingUseCaseProvider = Provider<GetNowPlayingUseCase>(
  (ref) => GetNowPlayingUseCase(ref.watch(moviesRepositoryProvider)),
);

final getPopularMoviesUseCaseProvider = Provider<GetPopularMoviesUseCase>(
  (ref) =>
      GetPopularMoviesUseCase(ref.watch(moviesRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// Dados — FutureProviders consumidos diretamente pela UI
// ─────────────────────────────────────────────────────────────────────────────

/// Filmes "Em Cartaz" — secção superior da Homepage (ecrã 01)
final nowPlayingProvider =
    FutureProvider<List<MovieEntity>>((ref) async {
  final useCase = ref.watch(getNowPlayingUseCaseProvider);
  final result = await useCase(NoParams());
  return result.fold(
    (failure) => throw Exception(failure.message),
    (movies) => movies,
  );
});

/// Filmes "Populares" — secção inferior da Homepage (ecrã 01)
final popularMoviesProvider =
    FutureProvider<List<MovieEntity>>((ref) async {
  final useCase = ref.watch(getPopularMoviesUseCaseProvider);
  final result = await useCase(NoParams());
  return result.fold(
    (failure) => throw Exception(failure.message),
    (movies) => movies,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Filtro de género activo na Homepage
// null = "Todos"; int = ID do género TMDB
// ─────────────────────────────────────────────────────────────────────────────

final selectedGenreProvider = StateProvider<int?>((ref) => null);

/// Filmes "Em Cartaz" já filtrados pelo género selecionado.
/// Derivado de [nowPlayingProvider] + [selectedGenreProvider].
final filteredNowPlayingProvider =
    Provider<AsyncValue<List<MovieEntity>>>((ref) {
  final moviesAsync = ref.watch(nowPlayingProvider);
  final genreId = ref.watch(selectedGenreProvider);

  return moviesAsync.whenData((movies) {
    if (genreId == null) return movies;
    return movies
        .where((m) => m.genreIds.contains(genreId))
        .toList();
  });
});

/// Filmes "Populares" já filtrados pelo género selecionado.
final filteredPopularProvider =
    Provider<AsyncValue<List<MovieEntity>>>((ref) {
  final moviesAsync = ref.watch(popularMoviesProvider);
  final genreId = ref.watch(selectedGenreProvider);

  return moviesAsync.whenData((movies) {
    if (genreId == null) return movies;
    return movies
        .where((m) => m.genreIds.contains(genreId))
        .toList();
  });
});