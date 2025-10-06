import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isOwnMessage;
  final VoidCallback? onDelete;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isOwnMessage,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwnMessage) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: message.senderAvatar != null
                  ? FileImage(FileImage(message.senderAvatar!))
                  : null,
              child: message.senderAvatar == null
                  ? Text(
                message.senderName?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 12),
              )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: onDelete,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isOwnMessage
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomLeft: isOwnMessage ? const Radius.circular(16) : const Radius.circular(4),
                    bottomRight: isOwnMessage ? const Radius.circular(4) : const Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isOwnMessage && message.senderName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          message.senderName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    _buildMessageContent(context),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(message.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isOwnMessage
                            ? theme.colorScheme.onPrimary.withOpacity(0.7)
                            : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isOwnMessage) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.messageType) {
      case 'image':
        return _buildImageContent(context);
      case 'file':
        return _buildFileContent(context);
      default:
        return _buildTextContent(context);
    }
  }

  Widget _buildTextContent(BuildContext context) {
    return Text(
      message.content,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: isOwnMessage
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.content.isNotEmpty) ...[
          _buildTextContent(context),
          const SizedBox(height: 8),
        ],
        ClipRRectborder(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: message.attachmentUrl!,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 200,
              height: 200,
              color: Colors.grey,
              child: const Icon(Icons.image),
            ),
            errorWidget: (context, url, error) => Container(
              width: 200,
              height: 200,
              color: Colors.grey,
              child: const Icon(Icons.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.attach_file,
            size: 20,
            color: isOwnMessage
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isOwnMessage
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (diff.inHours > 0) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
