import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/genre_chip.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/widgets/movie_card_list.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);

    final chips = <MapEntry<int?, String>>[
      const MapEntry(null, 'Todos'),
      ...AppConstants.genres.entries
          .take(5)
          .map((e) => MapEntry(e.key, e.value)),
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: TextField(
          controller: _ctrl,
          focusNode: _focus,
          decoration: InputDecoration(
            hintText: 'Pesquisar filmes...',
            border: InputBorder.none,
            hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          onChanged: (q) =>
              ref.read(searchProvider.notifier).search(q),
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _ctrl.clear();
                ref.read(searchProvider.notifier).clear();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              itemCount: chips.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GenreChip(
                  label: chips[i].value,
                  isSelected:
                      state.selectedGenreId == chips[i].key,
                  onTap: () => ref
                      .read(searchProvider.notifier)
                      .filterByGenre(chips[i].key),
                ),
              ),
            ),
          ),
          if (state.hasQuery) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.results.length} resultado(s)',
                    style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  DropdownButton<SortBy>(
                    value: state.sortBy,
                    underline: const SizedBox(),
                    items: SortBy.values
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.label,
                                style: const TextStyle(fontSize: 13)),
                          ),
                        )
                        .toList(),
                    onChanged: (s) {
                      if (s != null) {
                        ref
                            .read(searchProvider.notifier)
                            .changeSortBy(s);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
          const Divider(height: 1),
          Expanded(child: _body(state)),
        ],
      ),
    );
  }

  Widget _body(SearchState state) {
    if (!state.hasQuery) {
      return const EmptyView(
        message: 'Pesquisa por título de filme',
        icon: Icons.search,
      );
    }
    if (state.isLoading) return const LoadingShimmerList();
    if (state.error != null) {
      return ErrorView(
        message: state.error!,
        onRetry: () =>
            ref.read(searchProvider.notifier).search(state.query),
      );
    }
    if (!state.hasResults) {
      return EmptyView(
        message: 'Sem resultados para "${state.query}"',
        icon: Icons.movie_filter_outlined,
      );
    }
    return ListView.separated(
      itemCount: state.results.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, indent: 76),
      itemBuilder: (ctx, i) => MovieCardList(
        movie: state.results[i],
        onTap: () => context.push('/movie/${state.results[i].id}'),
      ),
    );
  }
}
