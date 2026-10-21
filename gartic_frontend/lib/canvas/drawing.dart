import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:x/MyApp.dart';
import 'package:x/logic/paintChannel.dart';
import 'package:x/theme/app_theme.dart';

/// The drawer's canvas: a toolbar (tool / colour / size / undo-redo-clear)
/// plus the drawing board. Live stroke data is streamed to the guessers.
class Drawing extends StatefulWidget {
  final PaintChannel paintChannel;
  final DrawingController drawingController;
  const Drawing(this.paintChannel, this.drawingController, {super.key});

  @override
  State<Drawing> createState() => _DrawingState();
}

class _DrawingState extends State<Drawing> {
  static const List<Color> _palette = [
    Color(0xffe74c3c),
    Color(0xffe67e22),
    Color(0xfff1c40f),
    Color(0xff2ecc71),
    Color(0xff1abc9c),
    Color(0xff3498db),
    Color(0xff9b59b6),
    Color(0xff2c3e50),
    Color(0xff000000),
  ];
  static const List<double> _strokeSizes = [3, 6, 12];
  static const List<IconData> _toolIcons = [
    Icons.edit_rounded,
    Icons.gesture_rounded,
    Icons.horizontal_rule_rounded,
    Icons.crop_square_rounded,
    Icons.circle_outlined,
  ];
  static const List<String> _toolNames = [
    'Pen',
    'Smooth',
    'Line',
    'Rectangle',
    'Circle',
  ];

  int _tool = 0;
  Color _color = _palette[0];
  double _stroke = _strokeSizes[1];

  @override
  void initState() {
    super.initState();
    _applyStyle();
  }

  PaintContent _contentFor(int index) {
    switch (index) {
      case 1:
        return SmoothLine();
      case 2:
        return StraightLine();
      case 3:
        return Rectangle();
      case 4:
        return Circle();
      case 0:
      default:
        return SimpleLine();
    }
  }

  void _applyStyle() {
    widget.drawingController.setPaintContent(_contentFor(_tool));
    widget.drawingController
        .setStyle(color: _color, strokeWidth: _stroke, style: PaintingStyle.stroke);
  }

  void _selectTool(int index) {
    setState(() => _tool = index);
    _applyStyle();
  }

  void _selectColor(Color color) {
    setState(() => _color = color);
    widget.drawingController.setStyle(color: color);
  }

  void _selectStroke(double width) {
    setState(() => _stroke = width);
    widget.drawingController.setStyle(strokeWidth: width);
  }

  // `PaintContent.toJson()` uses `runtimeType.toString()`, which dart2js
  // minifies in release builds (e.g. "minified:abc"). Stamp a stable type
  // name so the guesser can deserialize the payload in release too.
  static String _typeName(PaintContent content) {
    if (content is SmoothLine) return 'SmoothLine';
    if (content is StraightLine) return 'StraightLine';
    if (content is Rectangle) return 'Rectangle';
    if (content is Circle) return 'Circle';
    return 'SimpleLine';
  }

  // `getJsonList()` only exposes committed strokes (`_history`); the stroke
  // currently being drawn lives in `currentContent` until the gesture ends.
  // Include it so the guesser receives the drawing in (near) real time and is
  // independent of the raw-pointer vs gesture callback ordering.
  void _send() {
    final payload = <Map<String, dynamic>>[];
    for (final content in widget.drawingController.getHistory) {
      final json = content.toJson();
      json['type'] = _typeName(content);
      payload.add(json);
    }
    final current = widget.drawingController.currentContent;
    if (current != null) {
      final json = current.toJson();
      json['type'] = _typeName(current);
      payload.add(json);
    }
    widget.paintChannel.getListJson(payload);
  }

  @override
  Widget build(BuildContext context) {
    toogleValueForBlur = false;
    final width = MediaQuery.of(context).size.width * .75;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _toolbar(),
          const SizedBox(height: 8),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Listener(
              onPointerCancel: (s) {
                _send();
              },
              onPointerDown: (s) {
                _send();
              },
              onPointerMove: (s) {
                _send();
              },
              onPointerUp: (s) {
                _send();
                // Toolbar actions (clear/undo/redo) run on tap, after this raw
                // pointer callback; re-send shortly after to reflect them.
                Future.delayed(const Duration(milliseconds: 120), _send);
              },
              child: DrawingBoard(
                controller: widget.drawingController,
                background: SizedBox(width: width, height: 300),
                showDefaultActions: false,
                showDefaultTools: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ...List.generate(_toolIcons.length, (i) {
            final active = _tool == i;
            return Tooltip(
              message: _toolNames[i],
              child: _ToolButton(
                icon: _toolIcons[i],
                active: active,
                onTap: () => _selectTool(i),
              ),
            );
          }),
          const _ToolbarDivider(),
          ..._palette.map((c) => _ColorDot(
                color: c,
                active: c.toARGB32() == _color.toARGB32(),
                onTap: () => _selectColor(c),
              )),
          const _ToolbarDivider(),
          ..._strokeSizes.map((s) => _SizeDot(
                size: s,
                active: s == _stroke,
                onTap: () => _selectStroke(s),
              )),
          const _ToolbarDivider(),
          _ToolButton(
            icon: Icons.undo_rounded,
            active: false,
            onTap: () {
              widget.drawingController.undo();
              _send();
            },
          ),
          _ToolButton(
            icon: Icons.redo_rounded,
            active: false,
            onTap: () {
              widget.drawingController.redo();
              _send();
            },
          ),
          _ToolButton(
            icon: Icons.delete_outline_rounded,
            active: false,
            onTap: () {
              widget.drawingController.clear();
              _send();
            },
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _ToolButton(
      {required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          gradient: active ? AppGradients.primaryButton : null,
          color: active ? null : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: active ? Colors.white : Colors.white24, width: 1.5),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool active;
  final VoidCallback onTap;
  const _ColorDot(
      {required this.color, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? AppColors.accent : Colors.white54,
            width: active ? 3 : 1.5,
          ),
        ),
      ),
    );
  }
}

class _SizeDot extends StatelessWidget {
  final double size;
  final bool active;
  final VoidCallback onTap;
  const _SizeDot(
      {required this.size, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        width: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: active ? AppColors.accent : Colors.white24,
              width: active ? 2.5 : 1),
        ),
        child: Container(
          height: size,
          width: size,
          decoration: const BoxDecoration(
              color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white24,
    );
  }
}
