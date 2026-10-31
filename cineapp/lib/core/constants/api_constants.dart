class ApiConstants {

  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String backdropBaseUrl = 'https://image.tmdb.org/t/p/w780';
  static const String language = 'pt-PT';

  /// Token de leitura (v4) do TMDB, injetado em tempo de compilação:
  /// flutter run --dart-define=TMDB_TOKEN=o_teu_token
  static const String bearerToken = String.fromEnvironment('TMDB_TOKEN');
}
