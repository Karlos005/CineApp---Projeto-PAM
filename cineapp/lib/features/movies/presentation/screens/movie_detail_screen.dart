import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../booking/presentation/providers/booking_provider.dart';
import '../providers/movie_detail_provider.dart';

class MovieDetailScreen extends ConsumerWidget {
  final int movieId;
  const MovieDetailScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieAsync = ref.watch(movieDetailProvider(movieId));

    return movieAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
            title: const Text('Detalhes do Filme'),
            leading: BackButton(onPressed: () => context.pop())),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Detalhes do Filme')),
        body: ErrorView(message: e.toString()),
      ),
      data: (movie) {
        final cs = Theme.of(context).colorScheme;
        final genres = movie.genreIds
            .take(3)
            .map((id) => AppConstants.genres[id] ?? '')
            .where((n) => n.isNotEmpty)
            .join(' · ');

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: BackButton(onPressed: () => context.pop()),
            title: const Text('Detalhes do Filme'),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: movie.backdropPath.isNotEmpty
                              ? '${ApiConstants.backdropBaseUrl}${movie.backdropPath}'
                              : '${ApiConstants.imageBaseUrl}${movie.posterPath}',
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => Container(
                            height: 220,
                            color: cs.surfaceContainerHighest,
                            child: Icon(Icons.movie,
                                size: 64,
                                color: cs.onSurfaceVariant),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.25),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (movie.certification.isNotEmpty)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                movie.certification,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            [
                              if (genres.isNotEmpty) genres,
                              if (movie.formattedRuntime.isNotEmpty)
                                movie.formattedRuntime,
                            ].join(' · '),
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ..._stars(movie.voteAverage / 2),
                              const SizedBox(width: 8),
                              Text(
                                '${movie.voteAverage.toStringAsFixed(1)} / 10',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Sinopse',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            movie.overview.isNotEmpty
                                ? movie.overview
                                : 'Sem sinopse disponível.',
                            style: TextStyle(
                              fontSize: 14,
                              color: cs.onSurfaceVariant,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _InfoCard(
                                label: 'Duração',
                                value: movie.formattedRuntime.isNotEmpty
                                    ? movie.formattedRuntime
                                    : '—',
                              ),
                              _InfoCard(
                                label: 'Género',
                                value: movie.genreIds.isNotEmpty
                                    ? (AppConstants
                                            .genres[movie.genreIds.first] ??
                                        '—')
                                    : '—',
                              ),
                              _InfoCard(
                                label: 'Classif.',
                                value: movie.certification.isNotEmpty
                                    ? movie.certification
                                    : '—',
                              ),
                            ],
                          ),
                          const SizedBox(height: 88),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: PrimaryButton(
                    label: 'Reservar Bilhetes',
                    onPressed: () {
                      ref.read(bookingProvider.notifier).setMovie(movie);
                      context.push('/book/session');
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _stars(double rating) {
    return List.generate(5, (i) {
      if (i < rating.floor()) {
        return const Icon(Icons.star_rounded, size: 18, color: AppColors.accent);
      } else if (i < rating) {
        return const Icon(Icons.star_half_rounded, size: 18, color: AppColors.accent);
      } else {
        return const Icon(Icons.star_outline_rounded, size: 18, color: AppColors.accent);
      }
    });
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.outline),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
