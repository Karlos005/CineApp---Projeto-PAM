import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ticket_entity.dart';
import '../repositories/tickets_repository.dart';

class UpdateTicketStatusParams extends Equatable {
  final String userId;
  final String ticketId;
  final TicketStatus status;

  const UpdateTicketStatusParams({
    required this.userId,
    required this.ticketId,
    required this.status,
  });

  @override
  List<Object> get props => [userId, ticketId, status];
}

/// Atualiza o estado de um bilhete (ATIVO → USADO).
/// Corresponde ao PATCH no Firestore — satisfaz o requisito da API REST.
class UpdateTicketStatusUseCase
    implements UseCase<void, UpdateTicketStatusParams> {
  final TicketsRepository repository;
  const UpdateTicketStatusUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateTicketStatusParams params) {
    return repository.updateTicketStatus(
      params.userId,
      params.ticketId,
      params.status,
    );
  }
}