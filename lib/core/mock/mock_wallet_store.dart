import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wallet transaction kinds (mock).
enum TxnType { credit, debit, escrowHold, escrowRelease }

class WalletTxn {
  const WalletTxn({
    required this.id,
    required this.type,
    required this.label,
    this.counterparty,
    required this.date,
    required this.amountZarMinor,
    required this.status,
  });

  final String id;
  final TxnType type;
  final String label;
  final String? counterparty;
  final DateTime date;
  final int amountZarMinor;
  final String status;
}

/// Shared wallet fixture — read by the wallet feature and by the dashboard
/// wallet-glance chip (cross-feature data flows through core only).
class MockWalletStore {
  final int availableZarMinor = 284000;
  final int inEscrowZarMinor = 45000;

  final List<WalletTxn> transactions = [
    WalletTxn(
      id: 'txn-1',
      type: TxnType.escrowHold,
      label: 'Escrow hold — Fix a leaking kitchen pipe',
      counterparty: 'Sipho Dlamini',
      date: DateTime.now().subtract(const Duration(days: 1)),
      amountZarMinor: -45000,
      status: 'In Escrow',
    ),
    WalletTxn(
      id: 'txn-2',
      type: TxnType.escrowRelease,
      label: 'Escrow released — Garden cleanup',
      counterparty: 'Zanele Mthembu',
      date: DateTime.now().subtract(const Duration(days: 6)),
      amountZarMinor: 51000,
      status: 'Completed',
    ),
    WalletTxn(
      id: 'txn-3',
      type: TxnType.credit,
      label: 'Top up',
      date: DateTime.now().subtract(const Duration(days: 9)),
      amountZarMinor: 100000,
      status: 'Completed',
    ),
    WalletTxn(
      id: 'txn-4',
      type: TxnType.debit,
      label: 'Withdrawal to bank account',
      date: DateTime.now().subtract(const Duration(days: 14)),
      amountZarMinor: -75000,
      status: 'Completed',
    ),
    WalletTxn(
      id: 'txn-5',
      type: TxnType.escrowRelease,
      label: 'Escrow released — Maths tutoring',
      counterparty: 'David Botha',
      date: DateTime.now().subtract(const Duration(days: 20)),
      amountZarMinor: 25500,
      status: 'Completed',
    ),
  ];
}

final mockWalletStoreProvider =
    Provider<MockWalletStore>((ref) => MockWalletStore());
