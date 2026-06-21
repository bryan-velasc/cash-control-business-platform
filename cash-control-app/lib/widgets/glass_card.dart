import 'dart:ui';

import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {

  final Widget child;

  final double height;

  final double? width;

  const GlassCard({

    super.key,

    required this.child,

    required this.height,

    this.width,
  });

  @override
  Widget build(BuildContext context) {

    return ClipRRect(

      borderRadius:
          BorderRadius.circular(25),

      child: BackdropFilter(

        filter: ImageFilter.blur(

          sigmaX: 15,

          sigmaY: 15,
        ),

        child: Container(

          height: height,

          width: width,

          padding:
              const EdgeInsets.all(20),

          decoration: BoxDecoration(

            borderRadius:
                BorderRadius.circular(25),

            color: Colors.white
                .withOpacity(0.08),

            border: Border.all(

              color: Colors.white
                  .withOpacity(0.15),

              width: 1.5,
            ),
          ),

          child: child,
        ),
      ),
    );
  }
}