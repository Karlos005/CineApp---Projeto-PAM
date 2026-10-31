import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/ticket_model.dart';
import '../../domain/entities/ticket_entity.dart';

abstract class TicketsFirestoreDataSource {
  Future<void> createTicket(TicketModel ticket);
  Future<List<TicketModel>> getTickets(String userId);
  Future<void> updateTicketStatus(String ticketId, String userId, TicketStatus status);
}

class TicketsFirestoreDataSourceImpl implements TicketsFirestoreDataSource {
  final FirebaseFirestore firestore;
  TicketsFirestoreDataSourceImpl(this.firestore);

  CollectionReference _ticketsRef(String userId) =>
      firestore.collection('users').doc(userId).collection('tickets');

  @override
  Future<void> createTicket(TicketModel ticket) async {
    try {
      await _ticketsRef(ticket.userId)
          .doc(ticket.id)
          .set(ticket.toJson());
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Erro ao guardar bilhete');
    }
  }

  @override
  Future<List<TicketModel>> getTickets(String userId) async {
    try {
      final snapshot = await _ticketsRef(userId)
          .orderBy('bookedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => TicketModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Erro ao carregar bilhetes');
    }
  }

  @override
  Future<void> updateTicketStatus(String ticketId, String userId, TicketStatus status) async {
    try {
      await _ticketsRef(userId).doc(ticketId).update({
        'status': status.name,
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Erro ao atualizar bilhete');
    }
  }
}