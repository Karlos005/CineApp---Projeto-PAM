import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/session_entity.dart';

/// DataSource de sessões de cinema.
///
/// ⚠️ A API TMDB não fornece sessões reais.
/// Para o projeto académico usamos dados mock definidos em [AppConstants].
/// Em produção, esta classe chamaria a API do cinema (ex: Nos Cinemas API).
abstract class SessionsDataSource {
  Future<List<SessionEntity>> getSessionsForMovie(int movieId);
}

class SessionsDataSourceImpl implements SessionsDataSource {
  @override
  Future<List<SessionEntity>> getSessionsForMovie(int movieId) async {
    // Simula latência de rede (200–400ms)
    await Future.delayed(
      Duration(milliseconds: 200 + (movieId % 200)),
    );

    // Retorna os tipos de sala e horários definidos em AppConstants
    return AppConstants.mockSessions.entries
        .map(
          (entry) => SessionEntity(
            screenType: entry.key,
            times: List<String>.from(entry.value),
          ),
        )
        .toList();
  }
}