import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/api_constants.dart';
import '../theme/app_colors.dart';
import '../../../features/tickets/domain/entities/ticket_entity.dart';

class TicketCard extends StatelessWidget {
  final TicketEntity ticket;
  final VoidCallback onTap;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: ticket.moviePosterPath.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl:
                          '${ApiConstants.imageBaseUrl}${ticket.moviePosterPath}',
                      width: 48,
                      height: 68,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => _posterPlaceholder(cs),
                    )
                  : _posterPlaceholder(cs),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.movieTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(ticket.sessionDate)} · ${ticket.sessionTime} · ${ticket.screenType}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _StatusBadge(isAtivo: ticket.isAtivo),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEE, d MMM', 'pt').format(date);
  }

  Widget _posterPlaceholder(ColorScheme cs) {
    return Container(
      width: 48,
      height: 68,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(Icons.movie_outlined, size: 20, color: cs.onSurfaceVariant),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isAtivo;
  const _StatusBadge({required this.isAtivo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAtivo ? AppColors.badgeAtivo : AppColors.badgeUsado,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isAtivo ? 'ATIVO' : 'USADO',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isAtivo ? AppColors.black : Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
