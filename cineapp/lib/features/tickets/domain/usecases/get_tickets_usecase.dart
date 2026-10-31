import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ticket_entity.dart';
import '../repositories/tickets_repository.dart';

/// Obtém todos os bilhetes do utilizador autenticado.
/// [params] = userId (String).
class GetTicketsUseCase implements UseCase<List<TicketEntity>, String> {
  final TicketsRepository repository;
  const GetTicketsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TicketEntity>>> call(String userId) {
    return repository.getTickets(userId);
  }
}