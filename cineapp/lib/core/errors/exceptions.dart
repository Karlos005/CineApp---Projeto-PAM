class ServerException implements Exception {
  final String message;
  const ServerException({required this.message});
}
class FirestoreException implements Exception {
  final String message;
  const FirestoreException({required this.message});
}
class AuthException implements Exception {
  final String message;
  const AuthException({required this.message});
}