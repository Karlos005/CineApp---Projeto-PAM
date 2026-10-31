import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/booking_provider.dart';


class ChooseTicketsScreen extends ConsumerWidget {
  const ChooseTicketsScreen({super.key});

  static const double _price = 8.50;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider);
    final cs = Theme.of(context).colorScheme;
    final n = booking.numberOfTickets;
    final total = (n * _price).toStringAsFixed(2).replaceAll('.', ',');

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Número de Bilhetes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (booking.movie != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cs.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.movie!.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (booking.selectedDate != null)
                      Text(
                        DateFormat('EEEE, d MMMM yyyy', 'pt')
                            .format(booking.selectedDate!),
                        style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 13),
                      ),
                    if (booking.selectedTime != null &&
                        booking.selectedScreenType != null)
                      Text(
                        '${booking.selectedTime} · ${booking.selectedScreenType}',
                        style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 13),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 40),
            const Text(
              'Quantos bilhetes?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '€${_price.toStringAsFixed(2).replaceAll('.', ',')} por bilhete',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: cs.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CircleBtn(
                  icon: Icons.remove,
                  enabled: n > 1,
                  onTap: () => ref
                      .read(bookingProvider.notifier)
                      .setNumberOfTickets(n - 1),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    '$n',
                    style: const TextStyle(
                        fontSize: 44, fontWeight: FontWeight.bold),
                  ),
                ),
                _CircleBtn(
                  icon: Icons.add,
                  enabled: n < 10,
                  onTap: () => ref
                      .read(bookingProvider.notifier)
                      .setNumberOfTickets(n + 1),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(
                    '€$total',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Continuar',
              onPressed: () => context.push('/book/summary'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _CircleBtn(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      shape: const CircleBorder(),
      color: enabled ? cs.onSurface : cs.surfaceContainerHighest,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            size: 24,
            color: enabled ? cs.surface : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
