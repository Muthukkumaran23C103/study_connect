import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final VoidCallback onSendMessage;
  final VoidCallback onSendAttachment;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    required this.onSendAttachment,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: widget.onSendAttachment,
              icon: const Icon(Icons.attach_file),
              color: colorScheme.onSurfaceVariant,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                  ),
                  onSubmitted: _hasText ? (_) => widget.onSendMessage() : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: _hasText ? colorScheme.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _hasText ? widget.onSendMessage : null,
                icon: Icon(
                  Icons.send,
                  color: _hasText
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}