import 'package:flutter/material.dart';

class IncomeCard extends StatelessWidget {

  final double income;

  const IncomeCard({

    super.key,
    required this.income,
  });

  @override
  Widget build(BuildContext context) {

    return Expanded(

      child: Container(

        padding:
            const EdgeInsets.all(20),

        decoration: BoxDecoration(

          color:
              const Color(0xFF111111),

          borderRadius:
              BorderRadius.circular(
            20,
          ),
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(

              "Ingresos",

              style: TextStyle(
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 10),

            Text(

              "\$${income.toStringAsFixed(2)}",

              style: const TextStyle(

                fontSize: 24,

                fontWeight:
                    FontWeight.bold,

                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}