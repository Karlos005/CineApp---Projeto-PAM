import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/usecases/get_movie_detail_usecase.dart';
import 'popular_movies_provider.dart'; // moviesRepositoryProvider

// ─────────────────────────────────────────────────────────────────────────────
// Use Case
// ─────────────────────────────────────────────────────────────────────────────

final getMovieDetailUseCaseProvider = Provider<GetMovieDetailUseCase>(
  (ref) => GetMovieDetailUseCase(ref.watch(moviesRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// FutureProvider.family — recebe movieId como parâmetro
//
// Uso na UI:
//   final movieAsync = ref.watch(movieDetailProvider(movieId));
//   movieAsync.when(data: (m) => ..., loading: ..., error: ...);
// ─────────────────────────────────────────────────────────────────────────────

final movieDetailProvider =
    FutureProvider.family<MovieEntity, int>((ref, movieId) async {
  final useCase = ref.watch(getMovieDetailUseCaseProvider);
  final result = await useCase(movieId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (movie) => movie,
  );
});