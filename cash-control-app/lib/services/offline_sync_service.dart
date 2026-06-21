import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:uuid/uuid.dart';

import 'local_database_service.dart';

import 'transaction_service.dart';

class OfflineSyncService {
  static const String pendingTransactionsKey =
      "offline_transactions";

  static const Uuid uuid = Uuid();

  static Future<bool> hasInternet() async {
    final result =
        await Connectivity().checkConnectivity();

    return !result.contains(
      ConnectivityResult.none,
    );
  }

  static Future<void> savePendingTransaction({
    required String email,
    required String type,
    required String category,
    required double amount,
    required String description,
    String note = "",
    String sourceMode = "general",
    String? sourceTransactionId,
    String? sourceTransactionName,
  }) async {
    List current = [];

    final saved =
        LocalDatabaseService.getData(
      pendingTransactionsKey,
    );

    if (saved != null) {
      current = List.from(saved);
    }

    current.add({
      "local_id": uuid.v4(),
      "user_email": email,
      "type": type,
      "category": category,
      "amount": amount,
      "description": description,
      "note": note,
      "source_mode": sourceMode,
      "source_transaction_id": sourceTransactionId,
      "source_transaction_name": sourceTransactionName,
      "created_at": DateTime.now().toIso8601String(),
      "sync_status": "pending",
    });

    await LocalDatabaseService.saveData(
      key: pendingTransactionsKey,
      value: current,
    );
  }

  static Future<List<Map<String, dynamic>>>
      getPendingTransactions() async {
    final saved =
        LocalDatabaseService.getData(
      pendingTransactionsKey,
    );

    if (saved == null) {
      return [];
    }

    return List<Map<String, dynamic>>.from(
      saved.map(
        (item) => Map<String, dynamic>.from(item),
      ),
    );
  }

  static Future<int> getPendingCount() async {
    final pending =
        await getPendingTransactions();

    return pending.length;
  }

  static Future<void>
      clearPendingTransactions() async {
    await LocalDatabaseService.deleteData(
      pendingTransactionsKey,
    );
  }

  static Future<void> removePendingTransaction(
    String localId,
  ) async {
    final current =
        await getPendingTransactions();

    current.removeWhere(
      (item) => item["local_id"] == localId,
    );

    await LocalDatabaseService.saveData(
      key: pendingTransactionsKey,
      value: current,
    );
  }

  static Future<Map<String, dynamic>>
      syncPending() async {
    final online = await hasInternet();

    if (!online) {
      return {
        "synced": 0,
        "failed": 0,
        "message": "Sin conexión a internet",
      };
    }

    final pending =
        await getPendingTransactions();

    int synced = 0;
    int failed = 0;

    for (final tx in pending) {
      try {
        await TransactionService.createTransaction(
          email: tx["user_email"],
          type: tx["type"],
          category: tx["category"],
          amount: (tx["amount"] as num).toDouble(),
          description: tx["description"],
          note: tx["note"] ?? "",
          sourceMode:
              tx["source_mode"] ?? "general",
          sourceTransactionId:
              tx["source_transaction_id"],
          sourceTransactionName:
              tx["source_transaction_name"],
        );

        await removePendingTransaction(
          tx["local_id"],
        );

        synced++;
      } catch (e) {
        failed++;

        print("ERROR SYNC PENDING:");
        print(e);
      }
    }

    return {
      "synced": synced,
      "failed": failed,
      "message":
          "Sincronización terminada: $synced enviados, $failed fallidos",
    };
  }

  static Stream<List<ConnectivityResult>>
      connectivityStream() {
    return Connectivity().onConnectivityChanged;
  }
}