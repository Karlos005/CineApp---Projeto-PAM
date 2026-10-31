import 'package:equatable/equatable.dart';

enum TicketStatus { ativo, usado }

class TicketEntity extends Equatable {
  final String id;              // UUID gerado localmente
  final String userId;
  final int movieId;
  final String movieTitle;
  final String moviePosterPath;
  final String movieCertification; // M/12
  final DateTime sessionDate;
  final String sessionTime;     // "17:30"
  final String screenType;      // "ScreenX", "Standard"…
  final int numberOfTickets;
  final TicketStatus status;
  final DateTime bookedAt;

  const TicketEntity({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.movieTitle,
    required this.moviePosterPath,
    required this.movieCertification,
    required this.sessionDate,
    required this.sessionTime,
    required this.screenType,
    required this.numberOfTickets,
    required this.status,
    required this.bookedAt,
  });

  // Referência de bilhete visível ao utilizador (ex: #ABC-123-456)
  String get reference => '#${id.substring(0, 3).toUpperCase()}-'
      '${id.substring(3, 6).toUpperCase()}-'
      '${id.substring(6, 9).toUpperCase()}';

  bool get isAtivo => status == TicketStatus.ativo;

  @override
  List<Object?> get props => [id];
}