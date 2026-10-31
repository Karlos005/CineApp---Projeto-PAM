import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../tickets/presentation/providers/tickets_provider.dart';
import '../providers/booking_provider.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsState = ref.watch(ticketsProvider);
    final cs = Theme.of(context).colorScheme;
    final ticket = ticketsState.tickets.isNotEmpty
        ? ticketsState.tickets.first
        : null;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                const Icon(
                  Icons.check_circle_rounded,
                  size: 96,
                  color: Colors.green,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Reserva Confirmada!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (ticket != null) ...[
                  Text(
                    '${ticket.movieTitle}\n'
                    '${ticket.sessionTime} · ${ticket.screenType}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ticket.reference,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ] else
                  Text(
                    'O teu bilhete está disponível na tab Bilhetes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: cs.onSurfaceVariant, fontSize: 15),
                  ),
                const Spacer(),
                if (ticket != null)
                  PrimaryButton(
                    label: 'Ver Bilhete',
                    onPressed: () {
                      ref.read(bookingProvider.notifier).reset();
                      context.push('/tickets/${ticket.id}');
                    },
                  ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    ref.read(bookingProvider.notifier).reset();
                    context.go('/home');
                  },
                  child: const Text('Voltar ao Início'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
