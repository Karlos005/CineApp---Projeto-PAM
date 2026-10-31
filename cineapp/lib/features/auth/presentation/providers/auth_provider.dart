import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/send_password_reset_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_profile_photo_usecase.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Providers de infraestrutura — partilhados por toda a app
// (importar daqui quando outras features precisarem)
// ─────────────────────────────────────────────────────────────────────────────

final firebaseAuthProvider =
    Provider<fb.FirebaseAuth>((_) => fb.FirebaseAuth.instance);

final firestoreProvider =
    Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);

// ─────────────────────────────────────────────────────────────────────────────
// DataSource & Repository
// ─────────────────────────────────────────────────────────────────────────────

final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return AuthDataSourceImpl(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authDataSourceProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// Use Case providers
// ─────────────────────────────────────────────────────────────────────────────

final signInUseCaseProvider = Provider<SignInUseCase>(
  (ref) => SignInUseCase(ref.watch(authRepositoryProvider)),
);

final signUpUseCaseProvider = Provider<SignUpUseCase>(
  (ref) => SignUpUseCase(ref.watch(authRepositoryProvider)),
);

final signOutUseCaseProvider = Provider<SignOutUseCase>(
  (ref) => SignOutUseCase(ref.watch(authRepositoryProvider)),
);

final sendPasswordResetUseCaseProvider = Provider<SendPasswordResetUseCase>(
  (ref) => SendPasswordResetUseCase(ref.watch(authRepositoryProvider)),
);

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>(
  (ref) => UpdateProfileUseCase(ref.watch(authRepositoryProvider)),
);

final uploadProfilePhotoUseCaseProvider = Provider<UploadProfilePhotoUseCase>(
  (ref) => UploadProfilePhotoUseCase(ref.watch(authRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// Estado de Auth
// ─────────────────────────────────────────────────────────────────────────────

class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserEntity? user,
    bool clearUser = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final SignInUseCase _signIn;
  final SignUpUseCase _signUp;
  final SignOutUseCase _signOut;
  final SendPasswordResetUseCase _sendReset;
  final UpdateProfileUseCase _updateProfile;
  final UploadProfilePhotoUseCase _uploadPhoto;
  final AuthRepository _repository;

  AuthNotifier({
    required SignInUseCase signIn,
    required SignUpUseCase signUp,
    required SignOutUseCase signOut,
    required SendPasswordResetUseCase sendReset,
    required UpdateProfileUseCase updateProfile,
    required UploadProfilePhotoUseCase uploadPhoto,
    required AuthRepository repository,
  })  : _signIn = signIn,
        _signUp = signUp,
        _signOut = signOut,
        _sendReset = sendReset,
        _updateProfile = updateProfile,
        _uploadPhoto = uploadPhoto,
        _repository = repository,
        super(const AuthState()) {
    _listenToAuthChanges();
  }

  /// Escuta mudanças de sessão do Firebase em tempo real.
  /// Mantém estado sincronizado mesmo após hot-restart ou expiração de token.
  void _listenToAuthChanges() {
    _repository.authStateChanges.listen((user) {
      if (user != null) {
        state = state.copyWith(user: user, clearError: true);
      } else {
        state = state.copyWith(clearUser: true, clearError: true);
      }
    });
  }

  // ── Ações ─────────────────────────────────────────────────────────────────

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result =
        await _signIn(SignInParams(email: email, password: password));
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (user) => state = state.copyWith(isLoading: false, user: user),
    );
  }

  Future<void> signUp(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _signUp(
        SignUpParams(name: name, email: email, password: password));
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (user) => state = state.copyWith(isLoading: false, user: user),
    );
  }

  Future<void> signOut() async {
    await _signOut(NoParams());
    state = const AuthState();
  }

  /// Retorna true se o email foi enviado, false se houve erro.
  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _sendReset(email);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  /// Retorna true se o perfil foi atualizado com sucesso.
  Future<bool> updateProfile({required String name, String? phoneNumber}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _updateProfile(
      UpdateProfileParams(name: name, phoneNumber: phoneNumber),
    );
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false, user: user);
        return true;
      },
    );
  }

  /// Retorna true se a foto foi enviada e o perfil atualizado com sucesso.
  Future<bool> uploadProfilePhoto(Uint8List bytes) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _uploadPhoto(bytes);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false, user: user);
        return true;
      },
    );
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider exposto à UI
// ─────────────────────────────────────────────────────────────────────────────

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    signIn: ref.watch(signInUseCaseProvider),
    signUp: ref.watch(signUpUseCaseProvider),
    signOut: ref.watch(signOutUseCaseProvider),
    sendReset: ref.watch(sendPasswordResetUseCaseProvider),
    updateProfile: ref.watch(updateProfileUseCaseProvider),
    uploadPhoto: ref.watch(uploadProfilePhotoUseCaseProvider),
    repository: ref.watch(authRepositoryProvider),
  );
});