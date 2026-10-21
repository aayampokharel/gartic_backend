import 'package:flutter/material.dart';
import 'package:x/theme/app_theme.dart';

class WordForDrawer extends StatelessWidget {
  var singleValue;
  WordForDrawer(this.singleValue, {super.key});

  @override
  Widget build(BuildContext context) {
    final word = singleValue.toString().trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppGradients.wordBadge,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          const Text(
            'Your word:',
            style: TextStyle(
              fontFamily: AppText.body,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              word.isEmpty ? '...' : word,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppText.display,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
