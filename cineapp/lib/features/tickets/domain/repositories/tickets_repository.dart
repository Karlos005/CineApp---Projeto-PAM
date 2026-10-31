import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ticket_entity.dart';

abstract class TicketsRepository {
  Future<Either<Failure, void>> createTicket(TicketEntity ticket);
  Future<Either<Failure, List<TicketEntity>>> getTickets(String userId);
  Future<Either<Failure, void>> updateTicketStatus(String userId, String ticketId, TicketStatus status);
}