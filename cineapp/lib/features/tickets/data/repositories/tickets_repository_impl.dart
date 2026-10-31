import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/repositories/tickets_repository.dart';
import '../datasources/tickets_firestore_datasource.dart';
import '../models/ticket_model.dart';

/// ⚠️  NOTA: a assinatura de [updateTicketStatus] foi expandida para
/// incluir [userId], necessário para localizar o documento no Firestore
/// (caminho: users/{userId}/tickets/{ticketId}).
/// Actualiza também [tickets_repository.dart] e [update_ticket_status_usecase.dart]
/// de acordo.
class TicketsRepositoryImpl implements TicketsRepository {
  final TicketsFirestoreDataSource dataSource;

  TicketsRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, void>> createTicket(TicketEntity ticket) async {
    try {
      final model = TicketModel.fromEntity(ticket);
      await dataSource.createTicket(model);
      return const Right(null);
    } on FirestoreException catch (e) {
      return Left(FirestoreFailure(message: e.message));
    } catch (e) {
      return Left(FirestoreFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TicketEntity>>> getTickets(
      String userId) async {
    try {
      final models = await dataSource.getTickets(userId);
      return Right(models);
    } on FirestoreException catch (e) {
      return Left(FirestoreFailure(message: e.message));
    } catch (e) {
      return Left(FirestoreFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTicketStatus(
      String userId, String ticketId, TicketStatus status) async {
    try {
      await dataSource.updateTicketStatus(ticketId, userId, status);
      return const Right(null);
    } on FirestoreException catch (e) {
      return Left(FirestoreFailure(message: e.message));
    } catch (e) {
      return Left(FirestoreFailure(message: e.toString()));
    }
  }
}