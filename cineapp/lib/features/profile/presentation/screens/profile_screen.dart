import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/widgets/ticket_card.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../tickets/presentation/providers/tickets_provider.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final ticketsState = ref.watch(ticketsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Perfil'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 24),

          // Avatar com a foto de perfil, ou a inicial do nome como fallback
          Center(
            child: UserAvatar(
              radius: 44,
              photoUrl: user?.photoUrl,
              displayName: user?.displayName,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            user?.displayName ?? 'Utilizador',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          Center(
            child: Text(
              user?.email ?? '',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Center(
            child: OutlinedButton(
              onPressed: () => context.push('/profile/edit'),
              style: OutlinedButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 10),
              ),
              child: const Text('Editar Perfil'),
            ),
          ),
          const SizedBox(height: 28),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Os Meus Bilhetes',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.go('/tickets'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'Ver todos →',
                    style: TextStyle(
                        color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Mostra shimmer durante carregamento, mensagem vazia ou até 2 bilhetes recentes
          if (ticketsState.isLoading)
            const LoadingShimmerTickets(itemCount: 2)
          else if (ticketsState.tickets.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Ainda não tens bilhetes.',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            )
          else
            ...ticketsState.tickets.take(2).map(
                  (t) => TicketCard(
                    ticket: t,
                    onTap: () => context.push('/tickets/${t.id}'),
                  ),
                ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'DEFINIÇÕES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
          ),

          SwitchListTile(
            title: const Text('Notificações'),
            value: _notifications,
            onChanged: (v) => setState(() => _notifications = v),
          ),

          // Toggle de tema — alterna entre claro e escuro via themeProvider
          SwitchListTile(
            title: const Text('Tema Escuro'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: ref.watch(themeProvider.notifier).isDark,
            onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
          ),

          const Divider(indent: 16, endIndent: 16),

          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Terminar Sessão',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: _confirmSignOut,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Pede confirmação antes de fazer sign out para evitar saídas acidentais
  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Terminar Sessão'),
        content:
            const Text('Tens a certeza que queres terminar a sessão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sair',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authProvider.notifier).signOut();
    }
  }
}