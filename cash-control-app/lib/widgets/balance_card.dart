import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {

  final double balance;

  const BalanceCard({

    super.key,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(

          "Balance Total",

          style: TextStyle(
            color: Colors.grey.shade500,
          ),
        ),

        const SizedBox(height: 10),

        Text(

          "\$${balance.toStringAsFixed(2)}",

          style: const TextStyle(

            fontSize: 42,

            fontWeight:
                FontWeight.bold,

            color: Colors.white,
          ),
        ),
      ],
    );
  }
}