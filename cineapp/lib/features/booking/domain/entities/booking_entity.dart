import 'package:equatable/equatable.dart';
import '../../../movies/domain/entities/movie_entity.dart';


class BookingEntity extends Equatable {
  final MovieEntity movie;
  final DateTime date;
  final String screenType;  // "Standard", "ScreenX", "ScreenXL"…
  final String time;        // "17:30"
  final int numberOfTickets;
  final double pricePerTicket;

  const BookingEntity({
    required this.movie,
    required this.date,
    required this.screenType,
    required this.time,
    required this.numberOfTickets,
    this.pricePerTicket = 8.50,
  });

  /// Preço total (numberOfTickets × pricePerTicket)
  double get totalPrice => numberOfTickets * pricePerTicket;

  /// Preço formatado para exibir: "€17,00"
  String get formattedTotal =>
      '€${totalPrice.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  List<Object?> get props =>
      [movie.id, date, screenType, time, numberOfTickets];
}