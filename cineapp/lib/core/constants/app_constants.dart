// Tipos de sala e horários mock — em produção viriam de uma API própria
class AppConstants {
  static const List<String> screenTypes = [
    'Standard',
    'ScreenX',
    'ScreenX Atmos',
    'ScreenXL',
    'ScreenXL Atmos',
  ];

  static const Map<String, List<String>> mockSessions = {
    'Standard':       ['14:00', '16:30', '19:00', '21:30'],
    'ScreenX':        ['15:00', '17:30', '20:15'],
    'ScreenX Atmos':  ['18:00', '21:00'],
    'ScreenXL':       ['14:30', '17:00', '20:00'],
    'ScreenXL Atmos': ['19:30', '22:00'],
  };

  // Géneros TMDB com IDs
  static const Map<int, String> genres = {
    28:    'Ação',
    12:    'Aventura',
    16:    'Animação',
    35:    'Comédia',
    80:    'Crime',
    99:    'Documentário',
    18:    'Drama',
    10751: 'Família',
    14:    'Fantasia',
    36:    'História',
    27:    'Terror',
    10402: 'Música',
    9648:  'Mistério',
    10749: 'Romance',
    878:   'Sci-Fi',
    10770: 'Telefilme',
    53:    'Thriller',
    10752: 'Guerra',
    37:    'Western',
  };
}