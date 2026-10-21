import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/src/drawing_controller.dart';
import 'package:x/canvas/TurnProgressBar.dart';
import 'package:x/canvas/guesser.dart';
import 'package:x/theme/app_theme.dart';

class guesserStructure extends StatelessWidget {
  final String currentTurn;
  final dynamic forProgressBar;
  final dynamic paintStream;
  final DrawingController guesserController;

  guesserStructure({
    super.key,
    required this.currentTurn,
    required this.forProgressBar,
    required this.paintStream,
    required this.guesserController,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.75;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: width,
          child: const TurnBanner(
            title: 'Guess the drawing!',
            subtitle: 'Type your answer in the chat below.',
            icon: Icons.search_rounded,
            gradient: AppGradients.timer,
          ),
        ),
        const SizedBox(height: 10),
        TurnProgressBar(
          restartToken: 'guess-$currentTurn',
          maxWidth: width,
          fetchElapsed: forProgressBar.forProgressBar,
        ),
        const SizedBox(height: 10),
        Container(
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: StreamBuilder(
            stream: paintStream,
            builder: (context, snapshots) {
              return guesserContainer(guesserController, snapshots);
            },
          ),
        ),
      ],
    );
  }
}
