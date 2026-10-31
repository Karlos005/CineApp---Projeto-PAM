import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Documentos do Firestore têm um limite de 1 MiB. Guardamos a imagem em
/// Base64 dentro do próprio documento (sem Firebase Storage), por isso
/// limitamos o tamanho dos bytes originais para deixar margem ao overhead
/// do Base64 (~33%) e aos restantes campos do documento.
const int _maxPhotoBytes = 700 * 1024;

/// Contrato e implementação do acesso ao Firebase Auth + Firestore.
abstract class AuthDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String email, String password, String name);
  Future<void> signOut();
  Future<void> sendPasswordReset(String email);
  Future<UserModel> updateProfile({required String name, String? phoneNumber});
  Future<UserModel> uploadProfilePhoto(Uint8List bytes);
  Stream<UserModel?> get authStateChanges;
}

class AuthDataSourceImpl implements AuthDataSource {
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthDataSourceImpl(this._auth, this._firestore);

  // ── Sign In ────────────────────────────────────────────────────────────────

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException(message: 'Utilizador não encontrado.');
      }
      return _mergeWithFirestore(user);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(message: _mapCode(e.code));
    }
  }

  // ── Sign Up ────────────────────────────────────────────────────────────────

  @override
  Future<UserModel> signUp(
      String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException(message: 'Erro ao criar conta.');
      }

      // 1. Atualizar displayName no Firebase Auth
      await user.updateDisplayName(name.trim());
      await user.reload();

      // 2. Criar documento do utilizador no Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return UserModel(
        id: user.uid,
        email: email.trim(),
        displayName: name.trim(),
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(message: _mapCode(e.code));
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Password Reset ─────────────────────────────────────────────────────────

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(message: _mapCode(e.code));
    }
  }

  // ── Update Profile ─────────────────────────────────────────────────────────

  @override
  Future<UserModel> updateProfile(
      {required String name, String? phoneNumber}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utilizador não autenticado.');
    }
    try {
      await user.updateDisplayName(name.trim());
      await user.reload();
      await _firestore.collection('users').doc(user.uid).set({
        'name': name.trim(),
        if (phoneNumber != null) 'phoneNumber': phoneNumber.trim(),
      }, SetOptions(merge: true));

      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: name.trim(),
        photoUrl: user.photoURL,
        phoneNumber: phoneNumber?.trim(),
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(message: _mapCode(e.code));
    }
  }

  // ── Upload Profile Photo ───────────────────────────────────────────────────

  @override
  Future<UserModel> uploadProfilePhoto(Uint8List bytes) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Utilizador não autenticado.');
    }
    if (bytes.lengthInBytes > _maxPhotoBytes) {
      throw const AuthException(
        message: 'A imagem é demasiado grande. Escolhe uma foto mais pequena.',
      );
    }
    try {
      final dataUri = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      await _firestore.collection('users').doc(user.uid).set(
        {'photoUrl': dataUri},
        SetOptions(merge: true),
      );

      return _mergeWithFirestore(user);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(message: _mapCode(e.code));
    } on FirebaseException catch (e) {
      throw AuthException(message: 'Erro ao guardar a foto (${e.code}).');
    }
  }

  // ── Auth State Stream ──────────────────────────────────────────────────────

  @override
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap(
          (user) async => user != null ? _mergeWithFirestore(user) : null,
        );
  }

  /// Junta os dados do Firebase Auth com campos adicionais guardados no Firestore
  /// (ex: phoneNumber, photoUrl em Base64), que não existem no objeto User do
  /// Firebase Auth.
  Future<UserModel> _mergeWithFirestore(fb.User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: doc.data()?['photoUrl'] as String? ?? user.photoURL,
      phoneNumber: doc.data()?['phoneNumber'] as String?,
    );
  }

  // ── Error mapping ──────────────────────────────────────────────────────────

  String _mapCode(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Não existe conta com este email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou password incorretos.';
      case 'email-already-in-use':
        return 'Este email já está em uso.';
      case 'weak-password':
        return 'A password deve ter pelo menos 6 caracteres.';
      case 'invalid-email':
        return 'Endereço de email inválido.';
      case 'too-many-requests':
        return 'Demasiadas tentativas. Tenta mais tarde.';
      case 'network-request-failed':
        return 'Sem ligação à internet. Verifica a tua rede.';
      default:
        return 'Erro de autenticação ($code).';
    }
  }
}