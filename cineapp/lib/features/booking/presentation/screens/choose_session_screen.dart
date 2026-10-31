import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/booking_provider.dart';

class ChooseSessionScreen extends ConsumerWidget {
  const ChooseSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider);
    final cs = Theme.of(context).colorScheme;
    final dates = List.generate(
        7, (i) => DateTime.now().add(Duration(days: i)));

    final sessionsAsync = booking.movie != null
        ? ref.watch(sessionsProvider(booking.movie!.id))
        : null;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Escolher Sessão'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 88,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              itemCount: dates.length,
              itemBuilder: (ctx, i) {
                final date = dates[i];
                final isSel = booking.selectedDate != null &&
                    booking.selectedDate!.day == date.day &&
                    booking.selectedDate!.month == date.month;
                return GestureDetector(
                  onTap: () => ref
                      .read(bookingProvider.notifier)
                      .selectDate(date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 56,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.accent : cs.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSel ? AppColors.accent : cs.outline,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE', 'pt')
                              .format(date)
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isSel
                                ? AppColors.black
                                : cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isSel ? AppColors.black : cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: sessionsAsync == null
                ? Center(
                    child: Text(
                      'Seleciona um filme primeiro.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  )
                : sessionsAsync.when(
                    loading: () => const Center(
                        child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text(e.toString())),
                    data: (sessions) => ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: sessions.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final session = sessions[i];
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.screenType,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: session.times.map((time) {
                                  final isSel =
                                      booking.selectedScreenType ==
                                              session.screenType &&
                                          booking.selectedTime == time;
                                  return GestureDetector(
                                    onTap: () {
                                      ref
                                          .read(bookingProvider.notifier)
                                          .selectScreenType(
                                              session.screenType);
                                      ref
                                          .read(bookingProvider.notifier)
                                          .selectTime(time);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 150),
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSel
                                            ? AppColors.accent
                                            : cs.surface,
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isSel
                                              ? AppColors.accent
                                              : cs.outline,
                                        ),
                                      ),
                                      child: Text(
                                        time,
                                        style: TextStyle(
                                          fontWeight: isSel
                                              ? FontWeight.bold
                                              : FontWeight.w400,
                                          fontSize: 14,
                                          color: isSel
                                              ? AppColors.black
                                              : cs.onSurface,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),

          if (booking.isSessionSelected)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: PrimaryButton(
                label: 'Continuar',
                onPressed: () => context.push('/book/tickets'),
              ),
            ),
        ],
      ),
    );
  }
}
