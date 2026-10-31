import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/usecases/search_movies_usecase.dart';
import 'popular_movies_provider.dart'; // moviesRepositoryProvider

// ─────────────────────────────────────────────────────────────────────────────
// Use Case
// ─────────────────────────────────────────────────────────────────────────────

final searchMoviesUseCaseProvider = Provider<SearchMoviesUseCase>(
  (ref) => SearchMoviesUseCase(ref.watch(moviesRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// Opções de ordenação — usadas no ecrã Busca
// ─────────────────────────────────────────────────────────────────────────────

enum SortBy { popularity, rating, releaseDate, titleAZ }

extension SortByLabel on SortBy {
  String get label {
    switch (this) {
      case SortBy.popularity:
        return 'Popularidade';
      case SortBy.rating:
        return 'Rating';
      case SortBy.releaseDate:
        return 'Data';
      case SortBy.titleAZ:
        return 'A–Z';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estado
// ─────────────────────────────────────────────────────────────────────────────

class SearchState {
  final String query;
  final List<MovieEntity> results;
  final bool isLoading;
  final String? error;
  final int? selectedGenreId;   // null = sem filtro
  final SortBy sortBy;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.selectedGenreId,
    this.sortBy = SortBy.popularity,
  });

  bool get hasResults => results.isNotEmpty;
  bool get hasQuery => query.isNotEmpty;

  SearchState copyWith({
    String? query,
    List<MovieEntity>? results,
    bool? isLoading,
    String? error,
    bool clearError = false,
    int? selectedGenreId,
    bool clearGenre = false,
    SortBy? sortBy,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedGenreId:
          clearGenre ? null : (selectedGenreId ?? this.selectedGenreId),
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchMoviesUseCase _useCase;
  // Guarda os resultados brutos da API (antes de filtros/sort)
  List<MovieEntity> _rawResults = [];

  SearchNotifier(this._useCase) : super(const SearchState());

  /// Faz pesquisa na TMDB e aplica filtros/sort actuais.
  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _rawResults = [];
      state = const SearchState();
      return;
    }

    state = state.copyWith(
        query: trimmed, isLoading: true, clearError: true);

    final result = await _useCase(trimmed);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
        results: [],
      ),
      (movies) {
        _rawResults = movies;
        state = state.copyWith(
          isLoading: false,
          results: _applyFiltersAndSort(_rawResults),
        );
      },
    );
  }

  /// Filtra por género — não faz nova chamada à API.
  void filterByGenre(int? genreId) {
    state = state.copyWith(
      selectedGenreId: genreId,
      clearGenre: genreId == null,
    );
    state = state.copyWith(
      results: _applyFiltersAndSort(_rawResults),
    );
  }

  /// Muda a ordenação dos resultados actuais.
  void changeSortBy(SortBy option) {
    state = state.copyWith(sortBy: option);
    state = state.copyWith(
      results: _applyFiltersAndSort(_rawResults),
    );
  }

  /// Limpa tudo (usado quando o utilizador sai do ecrã Busca).
  void clear() {
    _rawResults = [];
    state = const SearchState();
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  List<MovieEntity> _applyFiltersAndSort(List<MovieEntity> movies) {
    var list = [...movies];

    // Filtro por género
    final gId = state.selectedGenreId;
    if (gId != null) {
      list = list.where((m) => m.genreIds.contains(gId)).toList();
    }

    // Ordenação
    switch (state.sortBy) {
      case SortBy.rating:
        list.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
        break;
      case SortBy.releaseDate:
        list.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
        break;
      case SortBy.titleAZ:
        list.sort((a, b) => a.title
            .toLowerCase()
            .compareTo(b.title.toLowerCase()));
        break;
      case SortBy.popularity:
        break; // A API já devolve por popularidade
    }

    return list;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider exposto à UI
// ─────────────────────────────────────────────────────────────────────────────

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.watch(searchMoviesUseCaseProvider));
});