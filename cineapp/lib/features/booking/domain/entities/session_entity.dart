import 'package:equatable/equatable.dart';

class SessionEntity extends Equatable {
  final String screenType;    // "Standard", "ScreenX", "ScreenX Atmos"…
  final List<String> times;   // ["14:00", "16:30", "19:00"]

  const SessionEntity({required this.screenType, required this.times});

  @override
  List<Object?> get props => [screenType];
}