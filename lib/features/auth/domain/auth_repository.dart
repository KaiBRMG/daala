/// Auth repository interface — Phase 1 is mocked; Firebase Auth arrives in
/// Phase 2 behind this same interface.
abstract class AuthRepository {
  Future<void> logIn({required String identifier, required String password});

  Future<void> signUp({
    required String fullName,
    required String identifier,
    required String password,
  });

  Future<void> verifyOtp(String code);

  Future<void> resendOtp();

  /// Mock KYC (VerifyNow deferred to Phase 8).
  Future<void> verifyIdentity();
}

class InvalidCredentialsException implements Exception {
  const InvalidCredentialsException();
}

class InvalidOtpException implements Exception {
  const InvalidOtpException();
}
