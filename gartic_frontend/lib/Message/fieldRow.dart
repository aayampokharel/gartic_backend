import 'package:flutter/material.dart';
import 'package:x/logic/ChatController.dart';
import 'package:x/theme/app_theme.dart';

Widget fieldRow(AsyncSnapshot noEntrySnapshot, ChatController chatCtrl,
    dynamic Function(String) insideOnPressed) {
  final bool readOnly = noEntrySnapshot.data ?? false;

  void submit(String text) {
    if (readOnly) return;
    if (text.trim().isEmpty) return;
    insideOnPressed(text.trim());
    chatCtrl.txtReader("");
  }

  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: TextField(
          controller: chatCtrl.controller(),
          readOnly: readOnly,
          textInputAction: TextInputAction.send,
          onSubmitted: submit,
          decoration: InputDecoration(
            isDense: true,
            hintText:
                readOnly ? 'Wait for your turn...' : 'Type your guess...',
            prefixIcon: const Icon(Icons.chat_bubble_outline, size: 20),
          ),
        ),
      ),
      const SizedBox(width: 10),
      SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed: readOnly ? null : () => submit(chatCtrl.txt()),
          style: ElevatedButton.styleFrom(
            backgroundColor: readOnly ? Colors.grey : AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 18),
          ),
          child: const Icon(Icons.send_rounded, size: 20),
        ),
      ),
    ],
  );
}
