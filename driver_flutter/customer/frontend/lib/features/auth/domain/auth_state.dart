enum AuthStatus {
  unknown,
  initializing,
  unauthenticated,
  sendingOtp,
  otpSent,
  verifyingOtp,
  authenticated,
  profileIncomplete,
  sessionExpired,
  loggingOut,
  error
}

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final String? phoneForOtp;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.errorMessage,
    this.phoneForOtp,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? phoneForOtp,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      phoneForOtp: phoneForOtp ?? this.phoneForOtp,
    );
  }
}
