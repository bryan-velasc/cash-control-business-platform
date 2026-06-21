import 'package:flutter/material.dart';

class TransactionsWidget
    extends StatelessWidget {

  final List transactions;

  const TransactionsWidget({

    super.key,

    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {

    return ListView.builder(

      shrinkWrap: true,

      physics:
          const NeverScrollableScrollPhysics(),

      itemCount:
          transactions.length,

      itemBuilder:
          (context, index) {

        final tx =
            transactions[index];

        return Card(

          color:
              const Color(
                  0xFF111111),

          child: ListTile(

            title: Text(

              tx["category"],

              style:
                  const TextStyle(
                color:
                    Colors.white,
              ),
            ),

            subtitle: Text(

              tx["description"],

              style:
                  TextStyle(
                color: Colors
                    .grey.shade400,
              ),
            ),

            trailing: Text(

              "\$${tx["amount"]}",

              style: TextStyle(

                color:
                    tx["type"] ==
                            "income"

                        ? Colors.green

                        : Colors.red,

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}