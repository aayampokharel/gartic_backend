import 'dart:convert';

import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';

void paintStreamUse(DrawingController drawingController2, snapshots) {
  if (snapshots.hasData) {
    List list = json.decode(snapshots.data.toString()).toList();

    // The drawer sends the complete list of contents every frame, so replace
    // the board instead of appending (which would duplicate strokes).
    drawingController2.clear();
    for (int i = 0; i < list.length; i++) {
      final String? type = list[i]["type"] as String?;
      if (type == "SimpleLine") {
        drawingController2
            .addContents(<PaintContent>[SimpleLine.fromJson(list[i])]);
      } else if (type == "SmoothLine") {
        drawingController2
            .addContents(<PaintContent>[SmoothLine.fromJson(list[i])]);
      } else if (type == "StraightLine") {
        drawingController2
            .addContents(<PaintContent>[StraightLine.fromJson(list[i])]);
      } else if (type == "Rectangle") {
        drawingController2
            .addContents(<PaintContent>[Rectangle.fromJson(list[i])]);
      } else if (type == "Circle") {
        drawingController2
            .addContents(<PaintContent>[Circle.fromJson(list[i])]);
      }
    }
  }
}
