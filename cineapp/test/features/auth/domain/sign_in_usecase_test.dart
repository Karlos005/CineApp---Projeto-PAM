import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cineapp/core/errors/failures.dart';
import 'package:cineapp/features/auth/domain/entities/user_entity.dart';
import 'package:cineapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:cineapp/features/auth/domain/usecases/sign_in_usecase.dart';
import 'sign_in_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(mockRepository);
  });

  const tParams = SignInParams(email: 'user@example.com', password: '123456');
  const tUser = UserEntity(id: 'user_001', email: 'user@example.com');

  group('SignInUseCase', () {
    test('deve retornar o utilizador quando a autenticação tem sucesso', () async {
      when(mockRepository.signIn(tParams.email, tParams.password))
          .thenAnswer((_) async => const Right(tUser));

      final result = await useCase(tParams);

      expect(result, const Right(tUser));
      verify(mockRepository.signIn(tParams.email, tParams.password));
      verifyNoMoreInteractions(mockRepository);
    });

    test('deve retornar AuthFailure quando as credenciais são inválidas', () async {
      when(mockRepository.signIn(tParams.email, tParams.password))
          .thenAnswer((_) async =>
              const Left(AuthFailure(message: 'Credenciais inválidas')));

      final result = await useCase(tParams);

      expect(result, const Left(AuthFailure(message: 'Credenciais inválidas')));
    });
  });
}
