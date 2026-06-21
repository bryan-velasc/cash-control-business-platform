import 'package:pdf/pdf.dart';

import 'package:pdf/widgets.dart' as pw;

import 'package:printing/printing.dart';

class PdfService {

  static Future<void> generateReport({

    required String email,

    required double balance,

    required double income,

    required double expenses,

    required List transactions,
  }) async {

    final pdf = pw.Document();

    pdf.addPage(

      pw.MultiPage(

        pageFormat: PdfPageFormat.a4,

        build: (context) => [

          pw.Text(

            "CASH-CONTROL",

            style: pw.TextStyle(

              fontSize: 28,

              fontWeight:
                  pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Text("Usuario: $email"),

          pw.Text("Balance: \$${balance.toStringAsFixed(2)}"),

          pw.Text("Ingresos: \$${income.toStringAsFixed(2)}"),

          pw.Text("Gastos: \$${expenses.toStringAsFixed(2)}"),

          pw.SizedBox(height: 30),

          pw.Text(

            "Movimientos",

            style: pw.TextStyle(

              fontSize: 22,

              fontWeight:
                  pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 20),

          ...transactions.map(

            (tx) => pw.Container(

              margin:
                  const pw.EdgeInsets.only(
                bottom: 10,
              ),

              padding:
                  const pw.EdgeInsets.all(10),

              decoration: pw.BoxDecoration(

                border: pw.Border.all(),
              ),

              child: pw.Column(

                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,

                children: [

                  pw.Text(
                    tx["category"],
                  ),

                  pw.Text(
                    tx["description"],
                  ),

                  pw.Text(
                    "\$${tx["amount"]}",
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );

    await Printing.layoutPdf(

      onLayout: (format) async =>
          pdf.save(),
    );
  }
}