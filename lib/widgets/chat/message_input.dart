import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback onSendImage;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    required this.onSendImage,
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
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.image),
          onPressed: widget.onSendImage,
          color: Theme.of(context).primaryColor,
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey!),
            ),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: null,
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  widget.onSendMessage(text);
                  _controller.clear();
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: _hasText ? Theme.of(context).primaryColor : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.send),
            onPressed: _hasText ? () {
              widget.onSendMessage(_controller.text);
              _controller.clear();
            } : null,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
