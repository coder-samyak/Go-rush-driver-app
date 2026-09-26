import 'token_manager.dart';

class SessionManager {
  final TokenManager _tokenManager;

  SessionManager(this._tokenManager);

  Future<void> initializeSession() async {
    // Perform startup validation, check token expiry logic, etc.
  }

  Future<void> logout() async {
    // Clear local session, cache, etc.
    await _tokenManager.clearTokens();
  }

  Future<bool> isSessionActive() async {
    return await _tokenManager.hasValidSession();
  }
}
