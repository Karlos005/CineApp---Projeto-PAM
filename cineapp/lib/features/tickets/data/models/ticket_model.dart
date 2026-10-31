import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ticket_entity.dart';

/// Model da camada de dados — faz parse do Firestore ↔ TicketEntity.
class TicketModel extends TicketEntity {
  const TicketModel({
    required super.id,
    required super.userId,
    required super.movieId,
    required super.movieTitle,
    required super.moviePosterPath,
    required super.movieCertification,
    required super.sessionDate,
    required super.sessionTime,
    required super.screenType,
    required super.numberOfTickets,
    required super.status,
    required super.bookedAt,
  });

  // ── Firestore → Model ─────────────────────────────────────────────────────

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      movieId: json['movieId'] as int,
      movieTitle: json['movieTitle'] as String,
      moviePosterPath: json['moviePosterPath'] as String? ?? '',
      movieCertification: json['movieCertification'] as String? ?? '',
      sessionDate: (json['sessionDate'] as Timestamp).toDate(),
      sessionTime: json['sessionTime'] as String,
      screenType: json['screenType'] as String,
      numberOfTickets: json['numberOfTickets'] as int,
      status: TicketStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String? ?? 'ativo'),
        orElse: () => TicketStatus.ativo,
      ),
      bookedAt: (json['bookedAt'] as Timestamp).toDate(),
    );
  }

  // ── Model → Firestore ─────────────────────────────────────────────────────

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'moviePosterPath': moviePosterPath,
      'movieCertification': movieCertification,
      'sessionDate': Timestamp.fromDate(sessionDate),
      'sessionTime': sessionTime,
      'screenType': screenType,
      'numberOfTickets': numberOfTickets,
      'status': status.name,
      'bookedAt': Timestamp.fromDate(bookedAt),
    };
  }

  // ── Entity → Model ────────────────────────────────────────────────────────

  factory TicketModel.fromEntity(TicketEntity entity) {
    return TicketModel(
      id: entity.id,
      userId: entity.userId,
      movieId: entity.movieId,
      movieTitle: entity.movieTitle,
      moviePosterPath: entity.moviePosterPath,
      movieCertification: entity.movieCertification,
      sessionDate: entity.sessionDate,
      sessionTime: entity.sessionTime,
      screenType: entity.screenType,
      numberOfTickets: entity.numberOfTickets,
      status: entity.status,
      bookedAt: entity.bookedAt,
    );
  }
}