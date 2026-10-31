import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cineapp/core/errors/failures.dart';
import 'package:cineapp/features/tickets/domain/entities/ticket_entity.dart';
import 'package:cineapp/features/tickets/domain/repositories/tickets_repository.dart';
import 'package:cineapp/features/tickets/domain/usecases/create_ticket_usecase.dart';
import 'create_ticket_usecase_test.mocks.dart';

@GenerateMocks([TicketsRepository])
void main() {
  late CreateTicketUseCase useCase;
  late MockTicketsRepository mockRepository;

  final tTicket = TicketEntity(
    id: 'abc123def',
    userId: 'user_001',
    movieId: 1,
    movieTitle: 'Dune',
    moviePosterPath: '/poster.jpg',
    movieCertification: 'M/12',
    sessionDate: DateTime(2026, 6, 20),
    sessionTime: '17:30',
    screenType: 'ScreenX',
    numberOfTickets: 2,
    status: TicketStatus.ativo,
    bookedAt: DateTime(2026, 6, 18),
  );

  setUp(() {
    mockRepository = MockTicketsRepository();
    useCase = CreateTicketUseCase(mockRepository);
  });

  group('CreateTicketUseCase', () {
    test('deve criar bilhete com sucesso', () async {
      when(mockRepository.createTicket(tTicket))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(tTicket);

      expect(result, const Right(null));
      verify(mockRepository.createTicket(tTicket));
    });

    test('deve retornar FirestoreFailure quando a criação falha', () async {
      when(mockRepository.createTicket(tTicket))
          .thenAnswer((_) async =>
              const Left(FirestoreFailure(message: 'Permissão negada')));

      final result = await useCase(tTicket);

      expect(result, const Left(FirestoreFailure(message: 'Permissão negada')));
    });
  });
}