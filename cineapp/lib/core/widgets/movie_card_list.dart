import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../../../features/movies/domain/entities/movie_entity.dart';
import 'loading_shimmer.dart';

class MovieCardList extends StatelessWidget {
  final MovieEntity movie;
  final VoidCallback onTap;

  const MovieCardList({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final genreNames = movie.genreIds
        .take(2)
        .map((id) => AppConstants.genres[id] ?? '')
        .where((n) => n.isNotEmpty)
        .join(' · ');

    final metaLine = [
      if (genreNames.isNotEmpty) genreNames,
      if (movie.formattedRuntime.isNotEmpty) movie.formattedRuntime,
      if (movie.certification.isNotEmpty) movie.certification,
    ].join(' · ');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: movie.posterPath.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl:
                          '${ApiConstants.imageBaseUrl}${movie.posterPath}',
                      width: 60,
                      height: 90,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const ShimmerBox(
                        width: 60,
                        height: 90,
                        borderRadius: 6,
                      ),
                      errorWidget: (_, _, _) => _thumb(cs),
                    )
                  : _thumb(cs),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (metaLine.isNotEmpty)
                    Text(
                      metaLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildStars(movie.voteAverage / 2),
                      const SizedBox(width: 6),
                      Text(
                        movie.voteAverage.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _thumb(ColorScheme cs) {
    return Container(
      width: 60,
      height: 90,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(Icons.movie_outlined, size: 24, color: cs.onSurfaceVariant),
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star_rounded, size: 14, color: AppColors.accent);
        } else if (i < rating) {
          return const Icon(Icons.star_half_rounded, size: 14, color: AppColors.accent);
        } else {
          return const Icon(Icons.star_outline_rounded, size: 14, color: AppColors.accent);
        }
      }),
    );
  }
}
