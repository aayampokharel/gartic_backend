import 'package:flutter/material.dart';
import 'package:x/theme/app_theme.dart';

/// Scrollable chat transcript with bubbles, system notices and auto-scroll.
class MessageList extends StatefulWidget {
  final List messages;
  final String currentName;
  final double height;
  const MessageList({
    super.key,
    required this.messages,
    required this.currentName,
    this.height = 260,
  });

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty) {
      return Container(
        height: widget.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.chatSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('No messages yet — say hi!',
            style: TextStyle(color: Colors.white54, fontFamily: AppText.body)),
      );
    }

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.chatSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: widget.messages.length,
        itemBuilder: (context, index) =>
            _buildMessage(widget.messages[index]),
      ),
    );
  }

  Widget _buildMessage(dynamic raw) {
    String name = '';
    String text = '';
    if (raw is Map) {
      name = (raw['Name'] ?? '').toString();
      text = (raw['Message'] ?? '').toString();
    } else {
      text = raw.toString();
    }

    if (text.trim().isEmpty) return const SizedBox.shrink();

    final isSystem = text.contains('JOINED THE CONVERSATION');
    final isCorrect = text.startsWith('Gave Correct Answer');

    if (isSystem || isCorrect) {
      return Align(
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isCorrect
                ? AppColors.success.withValues(alpha: 0.22)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isCorrect ? AppColors.success : Colors.white24,
            ),
          ),
          child: Text(
            isCorrect ? 'Correct! $name guessed it 🎉' : text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppText.body,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isCorrect ? AppColors.success : Colors.white70,
            ),
          ),
        ),
      );
    }

    final mine = name == widget.currentName;
    final bubbleColor = mine ? AppColors.primary : Colors.white10;
    final textColor = mine ? Colors.white : Colors.white;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(mine ? 14 : 4),
            bottomRight: Radius.circular(mine ? 4 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!mine)
              Text(name,
                  style: const TextStyle(
                      fontFamily: AppText.body,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cyan)),
            if (!mine) const SizedBox(height: 2),
            Text(text,
                style: TextStyle(
                    fontFamily: AppText.body, fontSize: 15, color: textColor)),
          ],
        ),
      ),
    );
  }
}
