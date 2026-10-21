import 'package:flutter/material.dart';
import 'package:x/theme/app_theme.dart';

/// Animated turn timer bar.
///
/// It always restarts at the beginning of a new turn. A turn is identified by
/// [restartToken] (the current drawer's name) — whenever it changes the bar is
/// rebuilt from scratch, so after every "Break" the bar starts empty again.
/// The whole turn lasts [totalSeconds] seconds.
class TurnProgressBar extends StatefulWidget {
  final Object restartToken;
  final double maxWidth;
  final double totalSeconds;
  final Future<String> Function()? fetchElapsed;

  const TurnProgressBar({
    super.key,
    required this.restartToken,
    required this.maxWidth,
    this.totalSeconds = 40,
    this.fetchElapsed,
  });

  @override
  State<TurnProgressBar> createState() => _TurnProgressBarState();
}

class _TurnProgressBarState extends State<TurnProgressBar> {
  double _beginFraction = 0;
  int _durationMs = 0;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _calibrate();
  }

  @override
  void didUpdateWidget(covariant TurnProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.restartToken != widget.restartToken) {
      _ready = false;
      _calibrate();
    }
  }

  /// Reads the server's elapsed time so a player who joins mid-turn sees the
  /// bar already partly filled instead of a full 20s bar.
  Future<void> _calibrate() async {
    double elapsed = 0;
    final fetch = widget.fetchElapsed;
    if (fetch != null) {
      try {
        elapsed = double.tryParse((await fetch()).trim()) ?? 0;
      } catch (_) {
        elapsed = 0;
      }
    }
    if (!mounted) return;
    final total = widget.totalSeconds;
    elapsed = elapsed.clamp(0, total).toDouble();
    setState(() {
      _beginFraction = elapsed / total;
      _durationMs = ((total - elapsed) * 1000).round();
      _ready = true;
    });
  }

  BoxDecoration _barDecoration() => BoxDecoration(
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
      );

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Container(
        height: 16,
        width: widget.maxWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.white.withValues(alpha: 0.12),
          border: Border.all(width: 2, color: Colors.white24),
        ),
      );
    }
    return TweenAnimationBuilder<double>(
      key: ValueKey(widget.restartToken),
      duration: Duration(milliseconds: _durationMs),
      curve: Curves.linear,
      tween: Tween<double>(
        begin: _beginFraction * widget.maxWidth,
        end: widget.maxWidth,
      ),
      builder: (context, value, child) => Container(
        height: 16,
        width: value,
        decoration: _barDecoration(),
      ),
    );
  }
}
