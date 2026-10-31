import 'package:equatable/equatable.dart';

/// Entidade de género de filme.
class GenreEntity extends Equatable {
  final int id;
  final String name;

  const GenreEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id];
}