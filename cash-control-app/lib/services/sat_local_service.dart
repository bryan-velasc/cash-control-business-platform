import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class SatLocalService {
  static const String boxName = "cash_control_local";

  static const String obligationsKey = "sat_obligations";
  static const String invoicesKey = "sat_invoices";

  static const Uuid uuid = Uuid();

  static Box get _box => Hive.box(boxName);

  static Future<List<Map<String, dynamic>>> getObligations() async {
    final saved = _box.get(obligationsKey);

    if (saved == null) {
      return [];
    }

    return List<Map<String, dynamic>>.from(
      saved.map(
        (item) => Map<String, dynamic>.from(item),
      ),
    );
  }

  static Future<void> addObligation({
    required String title,
    required String description,
    required DateTime dueDate,
    String status = "Pendiente",
  }) async {
    final obligations = await getObligations();

    obligations.insert(0, {
      "id": uuid.v4(),
      "title": title.trim(),
      "description": description.trim(),
      "due_date": dueDate.toIso8601String(),
      "status": status,
      "created_at": DateTime.now().toIso8601String(),
    });

    await _box.put(
      obligationsKey,
      obligations,
    );
  }

  static Future<void> updateObligationStatus({
    required String id,
    required String status,
  }) async {
    final obligations = await getObligations();

    final updated = obligations.map(
      (item) {
        if (item["id"] == id) {
          item["status"] = status;
        }

        return item;
      },
    ).toList();

    await _box.put(
      obligationsKey,
      updated,
    );
  }

  static Future<void> deleteObligation(
    String id,
  ) async {
    final obligations = await getObligations();

    obligations.removeWhere(
      (item) => item["id"] == id,
    );

    await _box.put(
      obligationsKey,
      obligations,
    );
  }

  static Future<List<Map<String, dynamic>>> getInvoices() async {
    final saved = _box.get(invoicesKey);

    if (saved == null) {
      return [];
    }

    return List<Map<String, dynamic>>.from(
      saved.map(
        (item) => Map<String, dynamic>.from(item),
      ),
    );
  }

  static Future<void> addInvoice({
    required String folio,
    required String issuer,
    required String concept,
    required double amount,
    required DateTime date,
    String type = "Recibida",
  }) async {
    final invoices = await getInvoices();

    invoices.insert(0, {
      "id": uuid.v4(),
      "folio": folio.trim(),
      "issuer": issuer.trim(),
      "concept": concept.trim(),
      "amount": amount,
      "date": date.toIso8601String(),
      "type": type,
      "created_at": DateTime.now().toIso8601String(),
    });

    await _box.put(
      invoicesKey,
      invoices,
    );
  }

  static Future<void> deleteInvoice(
    String id,
  ) async {
    final invoices = await getInvoices();

    invoices.removeWhere(
      (item) => item["id"] == id,
    );

    await _box.put(
      invoicesKey,
      invoices,
    );
  }

  static double getTotalInvoicesAmount(
    List<Map<String, dynamic>> invoices,
  ) {
    double total = 0;

    for (final invoice in invoices) {
      final value = invoice["amount"];

      if (value is num) {
        total += value.toDouble();
      } else {
        total += double.tryParse(
              value.toString(),
            ) ??
            0;
      }
    }

    return total;
  }
}