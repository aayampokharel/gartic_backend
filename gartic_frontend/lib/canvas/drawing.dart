import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:x/MyApp.dart';
import 'package:x/logic/paintChannel.dart';

class Drawing extends StatelessWidget {
  PaintChannel paintChannel;

  DrawingController drawingController;
  Drawing(this.paintChannel, this.drawingController, {super.key});
 
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
    for (final content in drawingController.getHistory) {
      final json = content.toJson();
      json['type'] = _typeName(content);
      payload.add(json);
    }
    final current = drawingController.currentContent;
    if (current != null) {
      final json = current.toJson();
      json['type'] = _typeName(current);
      payload.add(json);
    }
    paintChannel.getListJson(payload);
  }

  @override
  Widget build(BuildContext context) {
    toogleValueForBlur = false;
    return Container(
      width: MediaQuery.of(context).size.width * .75,
      height: 300,
      color: Colors.white,
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
          controller: drawingController,
          background: SizedBox(
              width: MediaQuery.of(context).size.width * .75, height: 300),
          showDefaultActions: true,
          showDefaultTools: true,
        ),
      ),
    );
  }
}
