import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ticket_entity.dart';
import '../repositories/tickets_repository.dart';

class CreateTicketUseCase implements UseCase<void, TicketEntity> {
  final TicketsRepository repository;
  const CreateTicketUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(TicketEntity ticket) {
    return repository.createTicket(ticket);
  }
}