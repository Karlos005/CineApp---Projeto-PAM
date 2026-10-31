import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/booking_provider.dart';


class BookingSummaryScreen extends ConsumerWidget {
  const BookingSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider);
    final entity = booking.toBookingEntity();
    final cs = Theme.of(context).colorScheme;

    if (entity == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resumo')),
        body: const Center(
            child: Text('Sessão inválida. Volta atrás e tenta de novo.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Resumo da Reserva'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Confirma os detalhes da tua reserva',
              style: TextStyle(
                  color: cs.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 24),
            _Row(label: 'Filme', value: entity.movie.title),
            _Row(
              label: 'Data',
              value: DateFormat('EEEE, d MMMM yyyy', 'pt')
                  .format(entity.date),
            ),
            _Row(label: 'Hora', value: entity.time),
            _Row(label: 'Sala', value: entity.screenType),
            _Row(
                label: 'Bilhetes',
                value: '${entity.numberOfTickets}'),
            _Row(
              label: 'Preço unit.',
              value:
                  '€${entity.pricePerTicket.toStringAsFixed(2).replaceAll('.', ',')}',
            ),
            const Divider(height: 32, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total a pagar',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  entity.formattedTotal,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Confirmar e Pagar',
              onPressed: () => context.push('/book/payment'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(
                    color: cs.onSurfaceVariant, fontSize: 14)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
