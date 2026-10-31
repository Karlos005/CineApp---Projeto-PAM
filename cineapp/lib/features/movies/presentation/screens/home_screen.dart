import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/genre_chip.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/widgets/movie_card_horizontal.dart';
import '../../../../core/widgets/movie_card_list.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/popular_movies_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowPlayingAsync = ref.watch(filteredNowPlayingProvider);
    final popularAsync = ref.watch(filteredPopularProvider);
    final selectedGenre = ref.watch(selectedGenreProvider);
    final user = ref.watch(authProvider).user;
    final cs = Theme.of(context).colorScheme;

    final chips = <MapEntry<int?, String>>[
      const MapEntry(null, 'Todos'),
      ...AppConstants.genres.entries
          .take(4)
          .map((e) => MapEntry(e.key, e.value)),
    ];

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (ctx, _) => [
            SliverAppBar(
              elevation: 0,
              floating: true,
              snap: true,
              titleSpacing: 16,
              title: const Text(
                'CineApp',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: UserAvatar(
                      radius: 18,
                      photoUrl: user?.photoUrl,
                      displayName: user?.displayName,
                    ),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  child: GestureDetector(
                    onTap: () => context.go('/search'),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: cs.outline),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(Icons.search, color: cs.onSurfaceVariant, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Pesquisar filmes...',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(nowPlayingProvider);
              ref.invalidate(popularMoviesProvider);
            },
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
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
                        isSelected: selectedGenre == chips[i].key,
                        onTap: () => ref
                            .read(selectedGenreProvider.notifier)
                            .state = chips[i].key,
                      ),
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Text(
                    'Em Cartaz',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 210,
                  child: switch (nowPlayingAsync) {
                    AsyncData(value: []) => const Center(
                        child: Text('Sem filmes em cartaz'),
                      ),
                    AsyncData(:final value) => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: value.length,
                        itemBuilder: (ctx, i) => MovieCardHorizontal(
                          movie: value[i],
                          onTap: () =>
                              context.push('/movie/${value[i].id}'),
                        ),
                      ),
                    AsyncError(:final error) =>
                      ErrorView(message: error.toString()),
                    _ => const LoadingShimmerRow(),
                  },
                ),

                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    'Populares',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                switch (popularAsync) {
                  AsyncData(value: []) => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                          child: Text('Sem resultados para este gÃ©nero')),
                    ),
                  AsyncData(:final value) => Column(
                      children: value
                          .map(
                            (m) => MovieCardList(
                              movie: m,
                              onTap: () =>
                                  context.push('/movie/${m.id}'),
                            ),
                          )
                          .toList(),
                    ),
                  AsyncError(:final error) =>
                    ErrorView(message: error.toString()),
                  _ => const LoadingShimmerList(),
                },
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}