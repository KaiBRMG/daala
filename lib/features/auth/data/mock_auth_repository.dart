import '../../../core/utils/mock_delay.dart';
import '../domain/auth_repository.dart';

/// Mock triggers (per DESIGN.md §3.12 "mock triggers"):
/// - password `wrong` → invalid credentials error banner
/// - OTP `0000` → invalid code error banner
class MockAuthRepository implements AuthRepository {
  @override
  Future<void> logIn(
      {required String identifier, required String password}) async {
    await mockNetworkDelay();
    if (password == 'wrong') throw const InvalidCredentialsException();
  }

  @override
  Future<void> signUp({
    required String fullName,
    required String identifier,
    required String password,
  }) async {
    await mockNetworkDelay();
  }

  @override
  Future<void> verifyOtp(String code) async {
    await mockNetworkDelay();
    if (code == '0000') throw const InvalidOtpException();
  }

  @override
  Future<void> resendOtp() => mockNetworkDelay();

  @override
  Future<void> verifyIdentity() => mockNetworkDelay();
}
