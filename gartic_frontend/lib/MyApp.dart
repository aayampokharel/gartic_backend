import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'dart:async';

import 'package:x/CorrectDialogue.dart';

import 'package:x/drawer/body.dart';
import 'package:x/drawer/header.dart';
import 'package:x/logic/apiservice.dart';
import 'package:x/logic/boolStream.dart';
import 'package:x/logic/channel.dart';
import 'package:x/logic/drawerStream.dart';
import 'package:x/Message/messageList.dart';
import 'package:x/okButtonControl.dart';
import 'package:x/theme/app_theme.dart';
import 'package:x/painterStructure.dart';
import 'package:x/main.dart';
import 'package:http/http.dart' as http;
import 'package:x/logic/ChatController.dart';

class MyApp extends StatefulWidget {
  final String currentName;
  final Future Function() getListOfWords;
  @override
  const MyApp(this.currentName, this.getListOfWords, {super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

bool toogleReadOnly = false; //! for textfield.

var toogleForTextFieldIfTrue =
    false; //@ if true after hitting correct answer , the client should be able to talk in break

var toogleValueForBlur = true;

class _MyAppState extends State<MyApp> {
  void toogleBlurSetState() {
    setState(() {
      toogleValueForBlur = false;
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Channel channel = Channel();

  final ChatController chatController = ChatController();
  final BoolStream boolStreamController = BoolStream();

  String currentTurn = "nope"; //! dummy value as nope.
  List listOfMessage = [];
  DrawerStream drawerStream = DrawerStream();
//! names channel is to get the lit of players wheen drawer is

  var responses;

  var messageStream;
  StreamSubscription? _messageSubscription;
  var forDrawerVariable;
  Map<String, int> drawerMap = {};

  @override
  void initState() {
    super.initState();

    channel.sendDataToChannel(
        widget.currentName, " JOINED THE CONVERSATION=========");
    // forDrawer().then((value) => drawerStream.add(value));
    responses = ApiService.post(widget.currentName);

    messageStream = channel.broadcastStream();
    _messageSubscription = messageStream.listen((data) {
      if (!mounted) return;
      setState(() {
        listOfMessage.add(json.decode(data.toString()));
      });
    });
  }

  dynamic insideOnPressed(String str) {
    // toogleHasData = false;
    if (singleValue == str) {
      if (singleValue != "") {
        toogleForTextFieldIfTrue =
            true; //@ if true , the client should be able to talk in break
        boolStreamController.add(true);

        channel.sendDataToChannel(widget.currentName, str);

        return showCorrectDialog(context);
      }
    } else {
      channel.sendDataToChannel(widget.currentName, str);
    }
  }

  List namelist = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // drawer: Drawer(
      //   child: Column(
      //     children: [
      //       // const Header(),
      //       SizedBox(
      //         height: 200,
      //         width: 200,
      //         child: Body(drawerStream: drawerStream),
      //       ),
      //     ],
      //   ),
      // ),
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.brush_rounded, size: 22),
            SizedBox(width: 8),
            Text('Draw & Guess', style: TextStyle(fontFamily: 'gravitas')),
          ],
        ),
        // leading: IconButton(
        //   onPressed: () async {
        //     var res =
        //         await http.get(Uri.parse('http://localhost:8080/listofnames'));

        //     Future.delayed(const Duration(seconds: 1), () {
        //       drawerStream.add(res.body);
        //     });
        //     _scaffoldKey.currentState?.openDrawer();
        //   },
        //   icon: const Icon(Icons.menu),
        // ),
      ),
      backgroundColor: AppColors.backgroundTop,
      body: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.background),
            ),
          ),
          FutureBuilder(
              future:
                  responses, //! responses compulsory cha cause esle add ni garirako cha the currentName to the list in the backend an return ing first  element which is irrelevant OR RETURNS BREAK IF ALL ARE IN BREAK but the thiing will only be returned after the adding of element in the liist
              builder: (context, snapshots) {
                if (snapshots.connectionState == ConnectionState.done) {
                  currentTurn = snapshots.data.toString();
                  return SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1024),
                        child: Column(
                          children: [
                            Painter(
                                widget.currentName,
                                currentTurn,
                                boolStreamController.add,
                                widget.getListOfWords,
                                toogleBlurSetState),
                            const SizedBox(height: 14),
                            messageStreamBuilder(),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return const SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                  );
                }
              }),
          Visibility(
            //! this is for the blurred initializer.JUST DISPLAYED INITIALLY.
            visible: toogleValueForBlur,
            child: IgnorePointer(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  color: AppColors.backgroundTop.withValues(alpha: 0.55),
                  height: double.infinity,
                  width: double.infinity,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 56,
                          width: 56,
                          child: CircularProgressIndicator(
                              strokeWidth: 4, color: AppColors.accent),
                        ),
                        const SizedBox(height: 18),
                        Text('Connecting to the game...',
                            style: AppText.onDark.copyWith(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  StreamBuilder<Object?> messageStreamBuilder() {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: [
                  MessageList(
                      messages: listOfMessage,
                      currentName: widget.currentName),
                  const SizedBox(height: 12),
                  StreamBuilder<bool>(
                      //! controls the read-only state after a correct answer.
                      stream: boolStreamController.stream,
                      builder: (context, noEntrySnapshot) {
                        return okButtonControl(
                            snapshot: snapshot,
                            noEntrySnapshot: noEntrySnapshot,
                            chatController: chatController,
                            insideOnPressed: insideOnPressed);
                      }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // Close the WebSocket channels
    channel.close();

    // Close the StreamControllers
    drawerStream.close();
    boolStreamController.close();
    _messageSubscription?.cancel();

    // Dispose the TextEditingController
    chatController.dispose();

    super.dispose();
  }
}
