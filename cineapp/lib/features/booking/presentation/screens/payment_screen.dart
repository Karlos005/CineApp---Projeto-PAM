import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../tickets/domain/entities/ticket_entity.dart';
import '../../../tickets/presentation/providers/tickets_provider.dart';
import '../providers/booking_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  // Índice do método de pagamento selecionado
  int _method = 0;
  bool _processing = false;

  // Lista estática de métodos de pagamento disponíveis
  static const _methods = [
    ('Cartão de Crédito/Débito', Icons.credit_card),
    ('MB Way', Icons.phone_android_outlined),
    ('ApplePay', Icons.computer_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingProvider);
    final cs = Theme.of(context).colorScheme;

    // Preço fixo de 8,50€ por bilhete, formatado para vírgula decimal
    final total = (booking.numberOfTickets * 8.50)
        .toStringAsFixed(2)
        .replaceAll('.', ',');

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Pagamento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Total: €$total',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            const Text(
              'Método de pagamento',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Renderiza cada método de pagamento como cartão selecionável
            ..._methods.asMap().entries.map((e) {
              final idx = e.key;
              final (label, icon) = e.value;
              final sel = _method == idx;
              return GestureDetector(
                onTap: () => setState(() => _method = idx),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    // Borda mais grossa e cor diferente quando selecionado
                    border: Border.all(
                      color: sel ? cs.onSurface : cs.outline,
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(icon,
                          size: 22,
                          color: sel
                              ? cs.onSurface
                              : cs.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: sel
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      // Ícone de confirmação visível apenas no método ativo
                      if (sel)
                        Icon(Icons.check_circle,
                            size: 20, color: cs.onSurface),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Pagar €$total',
              isLoading: _processing,
              onPressed: _pay,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pay() async {
    setState(() => _processing = true);
    final booking = ref.read(bookingProvider);
    final user = ref.read(authProvider).user;

    // Validação: utilizador autenticado e sessão completamente configurada
    if (user == null || !booking.isSessionSelected || booking.movie == null) {
      setState(() => _processing = false);
      return;
    }

    // Simula processamento do pagamento
    await Future.delayed(const Duration(milliseconds: 1500));

    // Gera ID único de 9 caracteres sem hífens para a referência do bilhete
    final id = const Uuid()
        .v4()
        .replaceAll('-', '')
        .substring(0, 9);

    final ticket = TicketEntity(
      id: id,
      userId: user.id,
      movieId: booking.movie!.id,
      movieTitle: booking.movie!.title,
      moviePosterPath: booking.movie!.posterPath,
      movieCertification: booking.movie!.certification,
      sessionDate: booking.selectedDate!,
      sessionTime: booking.selectedTime!,
      screenType: booking.selectedScreenType!,
      numberOfTickets: booking.numberOfTickets,
      status: TicketStatus.ativo,
      bookedAt: DateTime.now(),
    );

    // Persiste o bilhete e navega para confirmação ou mostra erro
    final ok =
        await ref.read(ticketsProvider.notifier).createTicket(ticket);

    setState(() => _processing = false);

    if (ok && mounted) {
      context.go('/book/confirmation');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao criar bilhete. Tenta novamente.')),
      );
    }
  }
}
