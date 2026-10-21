import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:x/MyApp.dart';
import 'package:x/theme/app_theme.dart';
import 'package:http/http.dart' as http;

//@ initial name / landing page.
class Name extends StatefulWidget {
  const Name({super.key});

  @override
  State<Name> createState() => _NameState();
}

class _NameState extends State<Name> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _tween;
  final TextEditingController loginController = TextEditingController();
  bool _showError = false;

  //? returns a single word from the backend (next word in the queue).
  Future getListOfWords() async {
    var response = await http
        .get(Uri.parse("http://localhost:8080/listofwords"))
        .timeout(const Duration(seconds: 10));
    return response.body;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    _tween = Tween<double>(begin: 40, end: 0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    loginController.addListener(() {
      if (_showError && loginController.text.trim().isNotEmpty) {
        setState(() => _showError = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    loginController.dispose();
    super.dispose();
  }

  void _join() {
    final name = loginController.text.trim();
    if (name.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyApp(name, getListOfWords),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isNarrow = size.width < 640;

    return Scaffold(
      body: AppBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/photos/Gartic.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.45)),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _tween,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, _tween.value),
                  child: Opacity(opacity: _controller.value, child: child),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: GlassCard(
                      padding: EdgeInsets.all(isNarrow ? 22 : 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 74,
                            width: 74,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: AppGradients.primaryButton,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.brush_rounded,
                                color: Colors.white, size: 38),
                          ),
                          const SizedBox(height: 18),
                          const Text('Draw & Guess',
                              textAlign: TextAlign.center,
                              style: AppText.title),
                          const SizedBox(height: 6),
                          const Text(
                            'Enter your name to join the game',
                            textAlign: TextAlign.center,
                            style: AppText.label,
                          ),
                          const SizedBox(height: 26),
                          TextField(
                            controller: loginController,
                            autofocus: true,
                            textAlign: TextAlign.center,
                            textInputAction: TextInputAction.go,
                            onSubmitted: (_) => _join(),
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: 'Your name',
                              errorText:
                                  _showError ? 'Please enter a name' : null,
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 52,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppGradients.primaryButton,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton(
                                onPressed: _join,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Play',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
