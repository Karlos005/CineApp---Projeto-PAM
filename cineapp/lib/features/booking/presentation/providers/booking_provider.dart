import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../../data/datasources/sessions_datasource.dart';
import '../../data/repositories/sessions_repository_impl.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/sessions_repository.dart';
import '../../domain/usecases/get_sessions_usecase.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Infra — Sessions
// ─────────────────────────────────────────────────────────────────────────────

final sessionsDataSourceProvider = Provider<SessionsDataSource>(
  (_) => SessionsDataSourceImpl(),
);

final sessionsRepositoryProvider = Provider<SessionsRepository>(
  (ref) => SessionsRepositoryImpl(ref.watch(sessionsDataSourceProvider)),
);

final getSessionsUseCaseProvider = Provider<GetSessionsUseCase>(
  (ref) => GetSessionsUseCase(ref.watch(sessionsRepositoryProvider)),
);

/// Sessões disponíveis para um dado movieId.
/// Usado no ecrã 03 (ChooseSessionScreen).
final sessionsProvider =
    FutureProvider.family<List<SessionEntity>, int>((ref, movieId) async {
  final useCase = ref.watch(getSessionsUseCaseProvider);
  final result = await useCase(movieId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (sessions) => sessions,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Estado do fluxo de reserva (partilhado entre ecrãs 03 → 07)
// ─────────────────────────────────────────────────────────────────────────────

class BookingState {
  final MovieEntity? movie;
  final DateTime? selectedDate;
  final String? selectedScreenType;
  final String? selectedTime;
  final int numberOfTickets;
  final bool isLoading;
  final String? error;

  const BookingState({
    this.movie,
    this.selectedDate,
    this.selectedScreenType,
    this.selectedTime,
    this.numberOfTickets = 1,
    this.isLoading = false,
    this.error,
  });

  bool get isSessionSelected =>
      selectedDate != null &&
      selectedScreenType != null &&
      selectedTime != null;

  /// Constrói o BookingEntity para exibir no ecrã de resumo (05).
  BookingEntity? toBookingEntity() {
    if (movie == null || !isSessionSelected) return null;
    return BookingEntity(
      movie: movie!,
      date: selectedDate!,
      screenType: selectedScreenType!,
      time: selectedTime!,
      numberOfTickets: numberOfTickets,
    );
  }

  BookingState copyWith({
    MovieEntity? movie,
    DateTime? selectedDate,
    String? selectedScreenType,
    bool clearScreenType = false,
    String? selectedTime,
    bool clearTime = false,
    int? numberOfTickets,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return BookingState(
      movie: movie ?? this.movie,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedScreenType: clearScreenType
          ? null
          : (selectedScreenType ?? this.selectedScreenType),
      selectedTime:
          clearTime ? null : (selectedTime ?? this.selectedTime),
      numberOfTickets: numberOfTickets ?? this.numberOfTickets,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(const BookingState());

  /// Chamado ao clicar "Reservar Bilhetes" no ecrã 02.
  void setMovie(MovieEntity movie) {
    state = BookingState(movie: movie); // reset completo
  }

  void selectDate(DateTime date) {
    state = state.copyWith(
      selectedDate: date,
      clearScreenType: true,
      clearTime: true,
    );
  }

  void selectScreenType(String type) {
    state = state.copyWith(selectedScreenType: type, clearTime: true);
  }

  void selectTime(String time) {
    state = state.copyWith(selectedTime: time);
  }

  void setNumberOfTickets(int n) {
    if (n < 1 || n > 10) return;
    state = state.copyWith(numberOfTickets: n);
  }

  void reset() => state = const BookingState();
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final bookingProvider =
    StateNotifierProvider<BookingNotifier, BookingState>(
  (_) => BookingNotifier(),
);