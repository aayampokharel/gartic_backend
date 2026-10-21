import 'package:flutter/material.dart';
import 'package:x/theme/app_theme.dart';

TweenAnimationBuilder<double> animationBar(BuildContext context) {
  return TweenAnimationBuilder(
    duration: const Duration(milliseconds: 19500),
    tween:
        Tween<double>(begin: 0, end: MediaQuery.of(context).size.width * 0.75),
    //! in this app , MEDIAQUERY is not to be used , as it rebuilds all the container depending on it and erases all drawing as it gets refreshed .Here , only for testing purpose .
    //@ SOLUTION : the solution for this is use 2 layout one for small mobile phones , and another one is for pc .ELSE LIKE GARTIC CLONE <horizontally scrollable .
    builder: (BuildContext context, dynamic value, Widget? child) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(width: 2, color: Colors.white24),
          gradient: AppGradients.timer,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.45),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        height: 16,
        width: value,
      );
    },
  );
}
