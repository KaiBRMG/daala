import '../../../core/mock/mock_wallet_store.dart';
import '../../../core/utils/debug_flags.dart';
import '../../../core/utils/mock_delay.dart';
import '../domain/wallet_repository.dart';

class MockWalletRepository implements WalletRepository {
  MockWalletRepository(this._store);

  final MockWalletStore _store;

  @override
  Future<WalletData> getWallet() async {
    await mockNetworkDelay();
    DebugFlags.maybeThrow();
    return WalletData(
      availableZarMinor: _store.availableZarMinor,
      inEscrowZarMinor: _store.inEscrowZarMinor,
      transactions: DebugFlags.maybeEmpty(_store.transactions),
    );
  }
}
