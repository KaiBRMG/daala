import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_session.dart';
import '../data/mock_auth_repository.dart';
import '../domain/auth_repository.dart';

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => MockAuthRepository());

final authControllerProvider = Provider<AuthController>(
    (ref) => AuthController(
        ref.watch(authRepositoryProvider), ref.watch(sessionProvider)));

/// Screen-facing auth actions. Returns `null` on success, or a
/// user-readable error-banner message.
class AuthController {
  AuthController(this._repository, this._session);

  final AuthRepository _repository;
  final MockSession _session;

  Future<String?> logIn(
      {required String identifier, required String password}) async {
    try {
      await _repository.logIn(identifier: identifier, password: password);
      _session.signIn();
      return null;
    } on InvalidCredentialsException {
      return 'Invalid credentials. Please try again.';
    }
  }

  Future<String?> signUp({
    required String fullName,
    required String identifier,
    required String password,
  }) async {
    await _repository.signUp(
        fullName: fullName, identifier: identifier, password: password);
    return null;
  }

  Future<String?> verifyOtp(String code) async {
    try {
      await _repository.verifyOtp(code);
      _session.signIn();
      return null;
    } on InvalidOtpException {
      return 'Invalid code. Please try again.';
    }
  }

  Future<void> resendOtp() => _repository.resendOtp();

  Future<void> verifyIdentityNow() async {
    await _repository.verifyIdentity();
    _session.markVerified();
  }
}

/// Field-level validators (mock — enough to exercise inline error states).
abstract final class AuthValidators {
  static String? requiredField(String value, String label) =>
      value.trim().isEmpty ? '$label is required' : null;

  static String? identifier(String value) =>
      value.trim().isEmpty ? 'Enter your phone number or email' : null;

  static String? password(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}
