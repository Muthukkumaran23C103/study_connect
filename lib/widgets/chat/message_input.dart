import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController textController;
  final VoidCallback onSendMessage;

  const MessageInput({
    super.key,
    required this.textController,
    required this.onSendMessage,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool _isTextNotEmpty = false;

  @override
  void initState() {
    super.initState();
    widget.textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.textController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final isNotEmpty = widget.textController.text.trim().isNotEmpty;
    if (isNotEmpty != _isTextNotEmpty) {
      setState(() {
        _isTextNotEmpty = isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Attachment button
        IconButton(
          icon: Icon(
            Icons.attach_file,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onPressed: () {
            // TODO: Implement attachment functionality
          },
        ),

        // Text input
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: widget.textController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _isTextNotEmpty ? widget.onSendMessage() : null,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Send button
        Container(
          decoration: BoxDecoration(
            color: _isTextNotEmpty
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Icons.send_rounded,
              color: _isTextNotEmpty
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            onPressed: _isTextNotEmpty ? widget.onSendMessage : null,
          ),
        ),
      ],
    );
  }
}