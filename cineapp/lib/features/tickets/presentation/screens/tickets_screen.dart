import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/widgets/ticket_card.dart';
import '../../../tickets/domain/entities/ticket_entity.dart';
import '../../../tickets/presentation/providers/tickets_provider.dart';

class TicketsScreen extends ConsumerWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ticketsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text('Os Meus Bilhetes'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Ativos'),
              Tab(text: 'Usados'),
            ],
          ),
        ),
        body: state.isLoading
            ? const LoadingShimmerTickets()
            : state.error != null
                ? ErrorView(
                    message: state.error!,
                    onRetry: () =>
                        ref.read(ticketsProvider.notifier).loadTickets(),
                  )
                : TabBarView(
                    children: [
                      _TicketList(
                        tickets: state.activeTickets,
                        emptyMessage:
                            'Não tens bilhetes ativos.\nReserva um filme!',
                        emptyAction: 'Ver filmes',
                        onEmptyAction: () => context.go('/home'),
                      ),
                      _TicketList(
                        tickets: state.usedTickets,
                        emptyMessage:
                            'Ainda não usaste nenhum bilhete.',
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _TicketList extends ConsumerWidget {
  final List<TicketEntity> tickets;
  final String emptyMessage;
  final String? emptyAction;
  final VoidCallback? onEmptyAction;

  const _TicketList({
    required this.tickets,
    required this.emptyMessage,
    this.emptyAction,
    this.onEmptyAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tickets.isEmpty) {
      return EmptyView(
        message: emptyMessage,
        icon: Icons.confirmation_number_outlined,
        actionLabel: emptyAction,
        onAction: onEmptyAction,
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(ticketsProvider.notifier).loadTickets(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: tickets.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (ctx, i) => TicketCard(
          ticket: tickets[i],
          onTap: () => context.push('/tickets/${tickets[i].id}'),
        ),
      ),
    );
  }
}
