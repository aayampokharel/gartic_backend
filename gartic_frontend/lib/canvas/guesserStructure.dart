import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/src/drawing_controller.dart';
import 'package:x/canvas/guesser.dart';
import 'package:x/canvas/guesserAniBar.dart';
import 'package:x/theme/app_theme.dart';

class guesserStructure extends StatelessWidget {
  bool toogleValueForProgressBar;

  var forProgressBar;

  var paintStream;

  DrawingController guesserController;

  guesserStructure(this.toogleValueForProgressBar, this.forProgressBar,
      this.paintStream, this.guesserController,
      {super.key});

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
        GuesserAnimationBar(
          toogleValueForProgressBar,
          forProgressBar,
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
