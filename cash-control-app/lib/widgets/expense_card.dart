import 'package:flutter/material.dart';

class ExpenseCard extends StatelessWidget {

  final double expenses;

  const ExpenseCard({

    super.key,
    required this.expenses,
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

              "Gastos",

              style: TextStyle(
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 10),

            Text(

              "\$${expenses.toStringAsFixed(2)}",

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