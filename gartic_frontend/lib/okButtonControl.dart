import 'package:flutter/material.dart';
import 'package:x/logic/ChatController.dart';
import 'package:x/Message/fieldRow.dart';
import 'package:x/theme/app_theme.dart';

class okButtonControl extends StatelessWidget {
  AsyncSnapshot<Object?> snapshot;
  AsyncSnapshot<bool> noEntrySnapshot;
  ChatController chatController;
  dynamic Function(String) insideOnPressed;
  okButtonControl({
    super.key,
    required this.snapshot,
    required this.noEntrySnapshot,
    required this.chatController,
    required this.insideOnPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!snapshot.hasData) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: fieldRow(noEntrySnapshot, chatController, insideOnPressed),
    );
  }
}
