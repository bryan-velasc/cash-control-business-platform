import 'package:flutter/material.dart';

class AiAdviceWidget
    extends StatelessWidget {

  final List advice;

  const AiAdviceWidget({

    super.key,
    required this.advice,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,

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

            "Asistente Financiero IA",

            style: TextStyle(

              fontSize: 20,

              fontWeight:
                  FontWeight.bold,

              color: Colors.white,
            ),
          ),

          const SizedBox(height: 15),

          ...advice.map(

            (item) => Padding(

              padding:
                  const EdgeInsets.only(
                bottom: 10,
              ),

              child: Text(

                "• $item",

                style: TextStyle(

                  color: Colors
                      .grey.shade300,

                  fontSize: 15,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}