import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cineapp/core/errors/failures.dart';
import 'package:cineapp/core/usecases/usecase.dart';
import 'package:cineapp/features/movies/domain/entities/movie_entity.dart';
import 'package:cineapp/features/movies/domain/repositories/movies_repository.dart';
import 'package:cineapp/features/movies/domain/usecases/get_now_playing_usecase.dart';
import 'get_now_playing_usecase_test.mocks.dart';

@GenerateMocks([MoviesRepository])
void main() {
  late GetNowPlayingUseCase useCase;
  late MockMoviesRepository mockRepository;

  setUp(() {
    mockRepository = MockMoviesRepository();
    useCase = GetNowPlayingUseCase(mockRepository);
  });

  final tMovies = [
    const MovieEntity(
      id: 1, title: 'Dune', overview: 'Epic sci-fi.',
      posterPath: '/poster.jpg', backdropPath: '/back.jpg',
      voteAverage: 8.0, releaseDate: '2024-01-01',
      genreIds: [28, 878], runtime: 155, certification: 'M/12',
    ),
  ];

  group('GetNowPlayingUseCase', () {
    test('deve retornar filmes em cartaz quando o repositório tem sucesso', () async {
      when(mockRepository.getNowPlaying())
          .thenAnswer((_) async => Right(tMovies));

      final result = await useCase(NoParams());

      expect(result, Right(tMovies));
      verify(mockRepository.getNowPlaying());
      verifyNoMoreInteractions(mockRepository);
    });

    test('deve retornar ServerFailure quando a API falha', () async {
      when(mockRepository.getNowPlaying())
          .thenAnswer((_) async =>
              const Left(ServerFailure(message: 'Erro de servidor')));

      final result = await useCase(NoParams());

      expect(result, const Left(ServerFailure(message: 'Erro de servidor')));
    });
  });
}