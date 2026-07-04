import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_wallet_store.dart';
import '../data/mock_wallet_repository.dart';
import '../domain/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>(
    (ref) => MockWalletRepository(ref.watch(mockWalletStoreProvider)));

final walletProvider =
    FutureProvider.autoDispose<WalletData>((ref) async {
  return ref.watch(walletRepositoryProvider).getWallet();
});
