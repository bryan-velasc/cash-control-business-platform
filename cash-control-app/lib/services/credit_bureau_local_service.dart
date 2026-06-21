import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class CreditBureauLocalService {
  static const String boxName = "cash_control_local";

  static const String accountsKey = "credit_accounts";
  static const String paymentsKey = "credit_payments";

  static const Uuid uuid = Uuid();

  static Box get _box => Hive.box(boxName);

  static Future<List<Map<String, dynamic>>> getAccounts() async {
    final saved = _box.get(accountsKey);

    if (saved == null) {
      return [];
    }

    return List<Map<String, dynamic>>.from(
      saved.map(
        (item) => Map<String, dynamic>.from(item),
      ),
    );
  }

  static Future<void> addAccount({
    required String name,
    required String type,
    required double limit,
    required double used,
    required DateTime paymentDate,
    String status = "Activa",
  }) async {
    final accounts = await getAccounts();

    accounts.insert(0, {
      "id": uuid.v4(),
      "name": name.trim(),
      "type": type.trim(),
      "limit": limit,
      "used": used,
      "payment_date": paymentDate.toIso8601String(),
      "status": status,
      "created_at": DateTime.now().toIso8601String(),
    });

    await _box.put(
      accountsKey,
      accounts,
    );
  }

  static Future<void> deleteAccount(
    String id,
  ) async {
    final accounts = await getAccounts();

    accounts.removeWhere(
      (item) => item["id"] == id,
    );

    await _box.put(
      accountsKey,
      accounts,
    );
  }

  static Future<void> updateAccountStatus({
    required String id,
    required String status,
  }) async {
    final accounts = await getAccounts();

    final updated = accounts.map(
      (item) {
        if (item["id"] == id) {
          item["status"] = status;
        }

        return item;
      },
    ).toList();

    await _box.put(
      accountsKey,
      updated,
    );
  }

  static Future<List<Map<String, dynamic>>> getPayments() async {
    final saved = _box.get(paymentsKey);

    if (saved == null) {
      return [];
    }

    return List<Map<String, dynamic>>.from(
      saved.map(
        (item) => Map<String, dynamic>.from(item),
      ),
    );
  }

  static Future<void> addPayment({
    required String accountName,
    required double amount,
    required DateTime date,
    required bool onTime,
    String note = "",
  }) async {
    final payments = await getPayments();

    payments.insert(0, {
      "id": uuid.v4(),
      "account_name": accountName.trim(),
      "amount": amount,
      "date": date.toIso8601String(),
      "on_time": onTime,
      "note": note.trim(),
      "created_at": DateTime.now().toIso8601String(),
    });

    await _box.put(
      paymentsKey,
      payments,
    );
  }

  static Future<void> deletePayment(
    String id,
  ) async {
    final payments = await getPayments();

    payments.removeWhere(
      (item) => item["id"] == id,
    );

    await _box.put(
      paymentsKey,
      payments,
    );
  }

  static double parseDouble(
    dynamic value,
  ) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  static double getTotalLimit(
    List<Map<String, dynamic>> accounts,
  ) {
    double total = 0;

    for (final account in accounts) {
      total += parseDouble(
        account["limit"],
      );
    }

    return total;
  }

  static double getTotalUsed(
    List<Map<String, dynamic>> accounts,
  ) {
    double total = 0;

    for (final account in accounts) {
      total += parseDouble(
        account["used"],
      );
    }

    return total;
  }

  static double getUtilizationPercentage(
    List<Map<String, dynamic>> accounts,
  ) {
    final totalLimit = getTotalLimit(
      accounts,
    );

    final totalUsed = getTotalUsed(
      accounts,
    );

    if (totalLimit <= 0) {
      return 0;
    }

    return (totalUsed / totalLimit) * 100;
  }

  static int getOnTimePayments(
    List<Map<String, dynamic>> payments,
  ) {
    return payments.where(
      (payment) {
        return payment["on_time"] == true;
      },
    ).length;
  }

  static int getLatePayments(
    List<Map<String, dynamic>> payments,
  ) {
    return payments.where(
      (payment) {
        return payment["on_time"] != true;
      },
    ).length;
  }

  static int estimateScore({
    required List<Map<String, dynamic>> accounts,
    required List<Map<String, dynamic>> payments,
  }) {
    int score = 650;

    final utilization =
        getUtilizationPercentage(accounts);

    final onTime = getOnTimePayments(payments);
    final late = getLatePayments(payments);

    if (utilization <= 10) {
      score += 70;
    } else if (utilization <= 30) {
      score += 45;
    } else if (utilization <= 50) {
      score += 10;
    } else if (utilization <= 80) {
      score -= 35;
    } else {
      score -= 80;
    }

    score += onTime * 6;
    score -= late * 35;

    if (accounts.length >= 2) {
      score += 20;
    }

    if (accounts.length > 5) {
      score -= 15;
    }

    if (score < 300) {
      score = 300;
    }

    if (score > 850) {
      score = 850;
    }

    return score;
  }

  static String getScoreLevel(
    int score,
  ) {
    if (score >= 760) {
      return "Excelente";
    }

    if (score >= 700) {
      return "Bueno";
    }

    if (score >= 640) {
      return "Regular";
    }

    if (score >= 580) {
      return "Bajo";
    }

    return "Riesgoso";
  }
}