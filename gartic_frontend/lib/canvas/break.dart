import 'package:flutter/material.dart';
import 'package:x/theme/app_theme.dart';

class BreakContainer extends StatelessWidget {
  //Future Function() getListOfWords;
  //void Function() setSingleValueWhenBreak;

  const BreakContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: MediaQuery.of(context).size.width * .75,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            gradient: AppGradients.primaryButton,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_bottom_rounded,
                  color: Colors.white, size: 28),
              SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Round over — resuming after a short break...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "fsgravity",
                      fontSize: 26,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          child: Image.asset(
            "assets/photos/flashClock.gif",
            fit: BoxFit.contain,
          ),
        ),
      ],
    );

    /// below code is for display of drawn elements.
  }
}
