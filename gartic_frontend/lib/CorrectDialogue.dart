import "package:flutter/material.dart";
import "package:x/theme/app_theme.dart";

Future showCorrectDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            icon: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                gradient: AppGradients.wordBadge,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events_rounded,
                  color: Colors.white, size: 32),
            ),
            title: const Text("Congratulations!", textAlign: TextAlign.center),
            content: const Text(
              "That's the correct answer.",
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text("Nice!"),
              ),
            ],
          )));
}
