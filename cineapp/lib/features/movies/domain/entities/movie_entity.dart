import 'package:equatable/equatable.dart';

class MovieEntity extends Equatable {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String releaseDate;
  final List<int> genreIds;
  final int runtime;          // duração em minutos
  final String certification; // classificação: M/12, M/16…

  const MovieEntity({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.genreIds,
    this.runtime = 0,
    this.certification = '',
  });

  // Converte runtime em "2h 28m"
  String get formattedRuntime {
    if (runtime == 0) return '';
    final h = runtime ~/ 60;
    final m = runtime % 60;
    return '${h}h ${m}m';
  }

  @override
  List<Object?> get props => [id];
}