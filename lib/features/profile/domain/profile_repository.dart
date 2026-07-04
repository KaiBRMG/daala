import 'app_notification.dart';
import 'merchant_profile.dart';

/// Profile repository interface — mocked in Phase 1.
abstract class ProfileRepository {
  /// Public profile for any poster (Merchant or Consumer) by id.
  Future<MerchantProfile> merchantById(String id);

  Future<List<AppNotification>> notifications();
}
