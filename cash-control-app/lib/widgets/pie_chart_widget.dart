import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

class PieChartWidget
    extends StatelessWidget {

  final double income;

  final double expenses;

  const PieChartWidget({

    super.key,

    required this.income,

    required this.expenses,
  });

  List<PieChartSectionData>
      generatePieData() {

    return [

      PieChartSectionData(

        value: income,

        title: "Ingresos",

        radius: 70,

        color: Colors.green,
      ),

      PieChartSectionData(

        value: expenses,

        title: "Gastos",

        radius: 70,

        color: Colors.red,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {

    return Container(

      height: 300,

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color:
            const Color(0xFF111111),

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Column(

        children: [

          const Text(

            "Distribución Financiera",

            style: TextStyle(

              fontSize: 20,

              fontWeight:
                  FontWeight.bold,

              color: Colors.white,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(

            child: PieChart(

              PieChartData(

                sections:
                    generatePieData(),

                centerSpaceRadius: 40,

                sectionsSpace: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}