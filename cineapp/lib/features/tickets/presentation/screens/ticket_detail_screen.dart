import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/tickets_provider.dart';

class TicketDetailScreen extends ConsumerWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ticketsProvider);
    final ticket = state.findById(ticketId);
    final cs = Theme.of(context).colorScheme;

    // Guarda de carregamento: mostra indicador enquanto os bilhetes são obtidos
    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('O Meu Bilhete')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Guarda de bilhete não encontrado (id inválido ou já eliminado)
    if (ticket == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('O Meu Bilhete'),
          leading: BackButton(onPressed: () => context.pop()),
        ),
        body: Center(
            child: Text('Bilhete não encontrado.',
                style: TextStyle(color: cs.onSurfaceVariant))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('O Meu Bilhete'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho com poster, título, data/hora e tipo de sala
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.outline),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster do filme com fallback para ícone caso a imagem falhe
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: ticket.moviePosterPath.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl:
                                '${ApiConstants.imageBaseUrl}${ticket.moviePosterPath}',
                            width: 56,
                            height: 80,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) =>
                                _posterPlaceholder(cs),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Data formatada em português (ex: "segunda-feira, 25 de junho de 2026")
                        Text(
                          DateFormat(
                                  'EEEE, d \'de\' MMMM \'de\' yyyy',
                                  'pt')
                              .format(ticket.sessionDate),
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant),
                        ),
                        Text(
                          ticket.sessionTime,
                          style: TextStyle(
                              fontSize: 13,
                              color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            ticket.screenType,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black),
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
            const SizedBox(height: 16),

            // Resumo compacto com data, hora, sala e número de bilhetes
            Row(
              children: [
                _InfoCol(
                  label: 'DATA',
                  value: DateFormat('d MMM', 'pt')
                      .format(ticket.sessionDate),
                ),
                _InfoCol(label: 'HORA', value: ticket.sessionTime),
                _InfoCol(label: 'SALA', value: ticket.screenType),
                _InfoCol(
                  label: 'BILHETES',
                  value: '× ${ticket.numberOfTickets}',
                ),
              ],
            ),
            const SizedBox(height: 16),

            _DashedDivider(color: cs.outline),
            const SizedBox(height: 20),

            // Gera um QR code por bilhete (máximo 2 exibidos lado a lado)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              children: List.generate(
                ticket.numberOfTickets > 1 ? 2 : 1,
                (i) => QrImageView(
                  data: '${ticket.id}-${i + 1}',
                  version: QrVersions.auto,
                  size: 130,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Apresentar à entrada',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: cs.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 6),

            // Referência alfanumérica do bilhete com espaçamento de letras
            Text(
              ticket.reference,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // Classificação etária — só renderiza se existir
            if (ticket.movieCertification.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ticket.movieCertification,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _posterPlaceholder(ColorScheme cs) => Container(
        width: 56,
        height: 80,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(Icons.movie_outlined,
            size: 24, color: cs.onSurfaceVariant),
      );
}

class _InfoCol extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCol({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.5),
              textAlign: TextAlign.center),
        ],
      ),
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
        // Verde para ativo, cinzento para usado
        color: isAtivo ? AppColors.badgeAtivo : AppColors.badgeUsado,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isAtivo ? 'ATIVO' : 'USADO',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isAtivo ? AppColors.black : Colors.white,
        ),
      ),
    );
  }
}

// Divisor tracejado construído com LayoutBuilder para ocupar toda a largura disponível
class _DashedDivider extends StatelessWidget {
  final Color color;
  const _DashedDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        const dashW = 6.0;
        const gap = 4.0;
        final count =
            (constraints.maxWidth / (dashW + gap)).floor();
        return Row(
          children: List.generate(
            count,
            (_) => Container(
              width: dashW,
              height: 1,
              margin: const EdgeInsets.only(right: gap),
              color: color,
            ),
          ),
        );
      },
    );
  }
}
