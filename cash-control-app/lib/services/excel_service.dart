import 'dart:typed_data';

import 'package:excel/excel.dart';

import 'package:file_saver/file_saver.dart';

class ExcelService {
  static Future<void> exportExcel({
    required String email,
    required double balance,
    required double income,
    required double expenses,
    required List transactions,
  }) async {
    final excel = Excel.createExcel();

    final sheet = excel['Reporte'];

    sheet.appendRow([
      TextCellValue(
        "CASH-CONTROL",
      )
    ]);

    sheet.appendRow([]);

    sheet.appendRow([
      TextCellValue("Usuario"),
      TextCellValue(email),
    ]);

    sheet.appendRow([
      TextCellValue("Balance"),
      DoubleCellValue(balance),
    ]);

    sheet.appendRow([
      TextCellValue("Ingresos"),
      DoubleCellValue(income),
    ]);

    sheet.appendRow([
      TextCellValue("Gastos"),
      DoubleCellValue(expenses),
    ]);

    sheet.appendRow([]);

    sheet.appendRow([
      TextCellValue("Categoría"),
      TextCellValue("Descripción"),
      TextCellValue("Tipo"),
      TextCellValue("Monto"),
    ]);

    for (var tx in transactions) {
      sheet.appendRow([
        TextCellValue(
          tx["category"],
        ),
        TextCellValue(
          tx["description"],
        ),
        TextCellValue(
          tx["type"],
        ),
        DoubleCellValue(
          tx["amount"].toDouble(),
        ),
      ]);
    }

    final bytes = excel.save();

    if (bytes != null) {
      Uint8List data =
          Uint8List.fromList(bytes);

      await FileSaver.instance.saveFile(
        name: "cash_control_report.xlsx",
        bytes: data,
        mimeType: MimeType.microsoftExcel,
      );
    }
  }
}