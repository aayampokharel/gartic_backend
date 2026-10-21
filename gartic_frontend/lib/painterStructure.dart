import 'dart:async';
import 'dart:convert';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter/material.dart';
import 'package:x/canvas/AnimationService.dart';
import 'package:x/canvas/TurnProgressBar.dart';
import 'package:x/canvas/break.dart';
import 'package:x/canvas/drawing.dart';
import 'package:x/canvas/guesserStructure.dart';
import 'package:x/WordForDrawer.dart';
import 'package:x/logic/checkChannel.dart';
import 'package:x/logic/paintChannel.dart';
import 'package:x/main.dart';
import 'package:x/theme/app_theme.dart';

class Painter extends StatefulWidget {
  @override
  State<Painter> createState() => _PainterState();
  String currentName;
  String currentTurn;
  Function(bool) localStreamForTextField;
  Future Function() getListOfWords;
  void Function() toogleBlurSetState;

  Painter(this.currentName, this.currentTurn, this.localStreamForTextField,
      this.getListOfWords, this.toogleBlurSetState,
      {super.key});
}

class _PainterState extends State<Painter> {
  late bool runBlurOnce;
  var localName;
  final DrawingController guesserController = DrawingController();
  final DrawingController drawingController = DrawingController();
  final paintChannel = PaintChannel();

  final checkChannel = CheckChannel();
//@ alertWebsocket() is for adding true so that the input field is readonly:true

  late Stream paintStream;
  late Stream checkStream;

  String? _lastTurnValue;
  bool _breakOverlayDismissed = false;

  /// Bumped every time a fresh word is fetched for the drawer so the turn
  /// timer always restarts from 0 for their turn.
  int _wordNonce = 0;

  AnimationService forProgressBar = AnimationService();

  @override
  void initState() {
    //@ alertWebsocket() is called to make input field is readonly while player is drawing
    super.initState();
    runBlurOnce = true;
    _initializer();

    if (widget.currentName == widget.currentTurn) {
      checkChannel.alertWebSocket();
    }
    paintStream = paintChannel.broadcastStream();
    checkStream = checkChannel
        .broadcastStream(); //@ this makes other things depend on it .
  }

  Future<void> _initializer() {
    return widget.getListOfWords().then((value) {
      setState(() {
        singleValue = jsonDecode(value).toString();
        localName = singleValue;
        _wordNonce++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.transparent,
      child: StreamBuilder(
          stream: checkStream,

          /// this is for checking if the turn is this particular user or not
          builder: (context, snapshott) {
            //! clear ONLY when the turn actually changes, otherwise every
            //! rebuild (e.g. incoming paint frames) wipes the board.
            final turnValue = snapshott.data?.toString();
            if (_lastTurnValue != turnValue) {
              _lastTurnValue = turnValue;
              _breakOverlayDismissed = false;
              drawingController.clear();
              guesserController.clear();
            }
            singleValue = localName;
            if (snapshott.data == widget.currentName) {
              widget.localStreamForTextField(true);

              ///again setting readonly for the input field for drawer
            }
            if (snapshott.data == widget.currentName && snapshott.hasData) {
              if (runBlurOnce) {
                Future.delayed(const Duration(milliseconds: 300),
                    () => widget.toogleBlurSetState());
                runBlurOnce = false;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TurnBanner(
                    title: 'Your turn to draw!',
                    subtitle: 'Sketch the word below — everyone else is guessing.',
                    icon: Icons.brush_rounded,
                  ),
                  const SizedBox(height: 10),
                  //! The drawer's own turn starts the moment they get the word,
                  //! so the bar must always run a fresh 0 -> end (no server
                  //! elapsed calibration, which used to freeze it at the end).
                  TurnProgressBar(
                    restartToken: 'draw-${widget.currentName}-$_wordNonce',
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        WordForDrawer(singleValue),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Drawing(paintChannel, drawingController),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              ///break is the data sent in the stream after a certain time for drawer to change the drawing power to someone else.
            } else if ((snapshott.data.toString() == "Break")) {
              singleValue = "";

              //! this is for not letting yellow player to write. working ...feri kina rewrite bhayo bhanda cause this painter is inside the streambuilder and already said its like server and setstate waiting for data and rebuilding the thing . so painter lai bahira pathaune from main.

              widget.getListOfWords().then((value) {
                localName = jsonDecode(value).toString();
                _wordNonce++;
              });

              if (!_breakOverlayDismissed) {
                _breakOverlayDismissed = true;
                Future.delayed(const Duration(milliseconds: 300),
                    () => widget.toogleBlurSetState());
              }
              return const BreakContainer();

              /// below code is for display of drawn elements.
            } else {
              //@ THIS is called for non-drawers ones.
              widget.localStreamForTextField(false);
              if (runBlurOnce) {
                Future.delayed(
                    const Duration(
                        milliseconds:
                            300), //initially even in drawer this future runs initially because else condition run huncha initially and then drawer ko ma espachi yellow display huncha , so this will run initially.so timer will be effective of this only. JUST FOR SAFETY ABOVE IS NOT REMOVED.
                    () => widget.toogleBlurSetState());
                runBlurOnce = false;
              }
              return guesserStructure(
                  currentTurn: turnValue ?? '',
                  forProgressBar: forProgressBar,
                  paintStream: paintStream,
                  guesserController: guesserController);
            }
          }),
    );
  }

  @override
  void dispose() {
    // Close the WebSocket channels
    paintChannel.close();
    checkChannel.close();

    // Dispose the drawing controllers
    drawingController.dispose();
    guesserController.dispose();

    super.dispose();
  }
}
