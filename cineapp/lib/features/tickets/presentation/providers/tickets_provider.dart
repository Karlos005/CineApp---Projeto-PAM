import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../auth/presentation/providers/auth_provider.dart'
    show authProvider, firestoreProvider;
import '../../data/datasources/tickets_firestore_datasource.dart';
import '../../data/repositories/tickets_repository_impl.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/repositories/tickets_repository.dart';
import '../../domain/usecases/create_ticket_usecase.dart';
import '../../domain/usecases/get_tickets_usecase.dart';
import '../../domain/usecases/update_ticket_status_usecase.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DataSource & Repository
// ─────────────────────────────────────────────────────────────────────────────

final ticketsFirestoreDataSourceProvider =
    Provider<TicketsFirestoreDataSource>((ref) {
  return TicketsFirestoreDataSourceImpl(ref.watch(firestoreProvider));
});

final ticketsRepositoryProvider = Provider<TicketsRepository>((ref) {
  return TicketsRepositoryImpl(
      ref.watch(ticketsFirestoreDataSourceProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// Use Case providers
// ─────────────────────────────────────────────────────────────────────────────

final createTicketUseCaseProvider = Provider<CreateTicketUseCase>(
  (ref) => CreateTicketUseCase(ref.watch(ticketsRepositoryProvider)),
);

final getTicketsUseCaseProvider = Provider<GetTicketsUseCase>(
  (ref) => GetTicketsUseCase(ref.watch(ticketsRepositoryProvider)),
);

final updateTicketStatusUseCaseProvider =
    Provider<UpdateTicketStatusUseCase>(
  (ref) => UpdateTicketStatusUseCase(ref.watch(ticketsRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// Estado
// ─────────────────────────────────────────────────────────────────────────────

class TicketsState {
  final List<TicketEntity> tickets;
  final bool isLoading;
  final String? error;

  const TicketsState({
    this.tickets = const [],
    this.isLoading = false,
    this.error,
  });

  List<TicketEntity> get activeTickets =>
      tickets.where((t) => t.status == TicketStatus.ativo).toList();

  List<TicketEntity> get usedTickets =>
      tickets.where((t) => t.status == TicketStatus.usado).toList();

  /// Encontra um bilhete pelo ID — usado em [TicketDetailScreen]
  TicketEntity? findById(String id) =>
      tickets.where((t) => t.id == id).firstOrNull;

  TicketsState copyWith({
    List<TicketEntity>? tickets,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return TicketsState(
      tickets: tickets ?? this.tickets,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class TicketsNotifier extends StateNotifier<TicketsState> {
  final GetTicketsUseCase _getTickets;
  final CreateTicketUseCase _createTicket;
  final UpdateTicketStatusUseCase _updateStatus;
  final String _userId;

  TicketsNotifier({
    required GetTicketsUseCase getTickets,
    required CreateTicketUseCase createTicket,
    required UpdateTicketStatusUseCase updateStatus,
    required String userId,
  })  : _getTickets = getTickets,
        _createTicket = createTicket,
        _updateStatus = updateStatus,
        _userId = userId,
        super(const TicketsState()) {
    if (userId.isNotEmpty) loadTickets();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadTickets() async {
    if (_userId.isEmpty) return;
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getTickets(_userId);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (tickets) =>
          state = state.copyWith(isLoading: false, tickets: tickets),
    );
  }

  // ── Create (POST ao Firestore) ────────────────────────────────────────────

  /// Cria bilhete no Firestore e adiciona ao estado local imediatamente.
  /// Retorna true se sucesso.
  Future<bool> createTicket(TicketEntity ticket) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _createTicket(ticket);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          tickets: [ticket, ...state.tickets],
        );
        return true;
      },
    );
  }

  // ── Update (PATCH ao Firestore) ───────────────────────────────────────────

  /// Marca bilhete como USADO — atualiza Firestore e estado local.
  Future<void> markAsUsed(String ticketId) async {
    final result = await _updateStatus(UpdateTicketStatusParams(
      userId: _userId,
      ticketId: ticketId,
      status: TicketStatus.usado,
    ));
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        final updated = state.tickets.map((t) {
          if (t.id != ticketId) return t;
          return TicketEntity(
            id: t.id,
            userId: t.userId,
            movieId: t.movieId,
            movieTitle: t.movieTitle,
            moviePosterPath: t.moviePosterPath,
            movieCertification: t.movieCertification,
            sessionDate: t.sessionDate,
            sessionTime: t.sessionTime,
            screenType: t.screenType,
            numberOfTickets: t.numberOfTickets,
            status: TicketStatus.usado,
            bookedAt: t.bookedAt,
          );
        }).toList();
        state = state.copyWith(tickets: updated);
      },
    );
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider exposto à UI
//
// Nota: quando o userId muda (ex: após logout/login), o provider
// é automaticamente recriado pelo Riverpod porque depende de authProvider.
// ─────────────────────────────────────────────────────────────────────────────

final ticketsProvider =
    StateNotifierProvider<TicketsNotifier, TicketsState>((ref) {
  final userId = ref.watch(authProvider).user?.id ?? '';

  return TicketsNotifier(
    getTickets: ref.watch(getTicketsUseCaseProvider),
    createTicket: ref.watch(createTicketUseCaseProvider),
    updateStatus: ref.watch(updateTicketStatusUseCaseProvider),
    userId: userId,
  );
});