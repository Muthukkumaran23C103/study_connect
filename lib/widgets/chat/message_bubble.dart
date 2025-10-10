import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isOwn;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isOwn,
  });

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays < 7) {
      return DateFormat('EEE HH:mm').format(timestamp);
    } else {
      return DateFormat('MMM d, HH:mm').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwn) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isOwn) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text(
                      message.senderName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isOwn
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(18).copyWith(
                      bottomLeft: isOwn ? const Radius.circular(18) : const Radius.circular(4),
                      bottomRight: isOwn ? const Radius.circular(4) : const Radius.circular(18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isOwn
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _formatTime(message.createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isOwn
                                  ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                                  : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                              fontSize: 11,
                            ),
                          ),
                          if (isOwn) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.done,
                              size: 12,
                              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isOwn) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Text(
                message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : 'Y',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
