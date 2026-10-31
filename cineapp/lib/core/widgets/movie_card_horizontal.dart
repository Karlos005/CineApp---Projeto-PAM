import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import '../../../features/movies/domain/entities/movie_entity.dart';
import 'loading_shimmer.dart';

class MovieCardHorizontal extends StatelessWidget {
  final MovieEntity movie;
  final VoidCallback onTap;

  const MovieCardHorizontal({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: movie.posterPath.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl:
                          '${ApiConstants.imageBaseUrl}${movie.posterPath}',
                      width: 120,
                      height: 160,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const ShimmerBox(
                        width: 120,
                        height: 160,
                        borderRadius: 8,
                      ),
                      errorWidget: (_, _, _) => _placeholder(cs),
                    )
                  : _placeholder(cs),
            ),
            const SizedBox(height: 6),
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme cs) {
    return Container(
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.movie_outlined, size: 40, color: cs.onSurfaceVariant),
    );
  }
}
