import '../../domain/entities/movie_entity.dart';

class MovieModel extends MovieEntity {
  const MovieModel({
    required super.id,
    required super.title,
    required super.overview,
    required super.posterPath,
    required super.backdropPath,
    required super.voteAverage,
    required super.releaseDate,
    required super.genreIds,
    super.runtime,
    super.certification,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String? ?? '',
      backdropPath: json['backdrop_path'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['release_date'] as String? ?? '',
      genreIds: json['genre_ids'] != null
          ? List<int>.from(json['genre_ids'])
          : (json['genres'] as List?)
                  ?.map<int>((g) => g['id'] as int)
                  .toList() ??
              [],
      runtime: json['runtime'] as int? ?? 0,
      // A classificação vem de release_dates no endpoint de detalhe
      certification: _extractCertification(json),
    );
  }

  static String _extractCertification(Map<String, dynamic> json) {
    try {
      final releaseDates = json['release_dates']?['results'] as List?;
      if (releaseDates == null) return '';
      final ptEntry = releaseDates.firstWhere(
        (e) => e['iso_3166_1'] == 'PT',
        orElse: () => releaseDates.firstWhere(
          (e) => e['iso_3166_1'] == 'US',
          orElse: () => null,
        ),
      );
      if (ptEntry == null) return '';
      final releaseDatesInner = ptEntry['release_dates'] as List?;
      return releaseDatesInner?.first['certification'] as String? ?? '';
    } catch (_) {
      return '';
    }
  }
}