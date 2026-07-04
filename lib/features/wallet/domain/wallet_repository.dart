import '../../../core/mock/mock_wallet_store.dart';

/// Wallet snapshot (DESIGN.md §3.11 data requirements).
class WalletData {
  const WalletData({
    required this.availableZarMinor,
    required this.inEscrowZarMinor,
    required this.transactions,
  });

  final int availableZarMinor;
  final int inEscrowZarMinor;
  final List<WalletTxn> transactions;
}

/// Wallet repository interface — mock in Phase 1; TradeSafe wallet flow
/// arrives in Phase 7.
abstract class WalletRepository {
  Future<WalletData> getWallet();
}
