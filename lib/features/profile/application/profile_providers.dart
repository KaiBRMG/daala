import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_profile_repository.dart';
import '../domain/app_notification.dart';
import '../domain/merchant_profile.dart';
import '../domain/profile_repository.dart';

final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) => MockProfileRepository());

final merchantProfileProvider = FutureProvider.autoDispose
    .family<MerchantProfile, String>((ref, id) async {
  return ref.watch(profileRepositoryProvider).merchantById(id);
});

final notificationsProvider =
    FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  return ref.watch(profileRepositoryProvider).notifications();
});

enum MerchantProfileTab { portfolio, reviews, about }

class MerchantProfileTabNotifier extends Notifier<MerchantProfileTab> {
  @override
  MerchantProfileTab build() => MerchantProfileTab.portfolio;

  void set(MerchantProfileTab tab) => state = tab;
}

final merchantProfileTabProvider =
    NotifierProvider<MerchantProfileTabNotifier, MerchantProfileTab>(
        MerchantProfileTabNotifier.new);
