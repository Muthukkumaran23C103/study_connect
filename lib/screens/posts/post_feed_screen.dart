import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/post_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../core/models/post_model.dart';

class PostFeedScreen extends StatefulWidget {
  final int? groupId;

  const PostFeedScreen({Key? key, this.groupId}) : super(key: key);

  @override
  State<PostFeedScreen> createState() => _PostFeedScreenState();
}

class _PostFeedScreenState extends State<PostFeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.groupId != null) {
        context.read<PostProvider>().loadGroupPosts(widget.groupId!);
      } else {
        context.read<PostProvider>().loadAllPosts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          widget.groupId != null ? 'Group Posts' : 'All Posts',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showCreatePostDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          if (postProvider.isLoading && postProvider.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (postProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text('Error: \${postProvider.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.groupId != null) {
                        postProvider.loadGroupPosts(widget.groupId!);
                      } else {
                        postProvider.loadAllPosts();
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (widget.groupId != null) {
                await postProvider.loadGroupPosts(widget.groupId!);
              } else {
                await postProvider.loadAllPosts();
              }
            },
            child: postProvider.posts.isEmpty
                ? const Center(child: Text('No posts yet'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: postProvider.posts.length,
              itemBuilder: (context, index) {
                final post = postProvider.posts[index];
                return _buildPostCard(context, post);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, Post post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    post.authorName[0].toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTime(post.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag_outlined),
                          SizedBox(width: 8),
                          Text('Report'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'report') {
                      _reportPost(post);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content
            Text(
              post.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final currentUser = authProvider.currentUser;
                    if (currentUser == null) return const SizedBox.shrink();

                    return TextButton.icon(
                      onPressed: () {
                        context.read<PostProvider>().toggleLike(post.id!, currentUser.id.toString());
                      },
                      icon: const Icon(Icons.thumb_up_outlined),
                      label: Text('\${post.likes.length} Likes'),
                    );
                  },
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Open comments
                  },
                  icon: const Icon(Icons.comment_outlined),
                  label: Text('\${post.comments.length} Comments'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '\${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '\${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '\${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _reportPost(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: const Text('Are you sure you want to report this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post reported')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _showCreatePostDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              textController: titleController,
              label: 'Title',
              hintText: 'Enter post title',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              textController: contentController,
              label: 'Content',
              hintText: 'What would you like to share?',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final currentUser = authProvider.currentUser;
              if (currentUser == null) return const SizedBox.shrink();

              return CustomButton(
                text: 'Post',
                onPressed: () async {
                  if (titleController.text.trim().isNotEmpty &&
                      contentController.text.trim().isNotEmpty) {
                    await context.read<PostProvider>().createPost(
                      title: titleController.text.trim(),
                      content: contentController.text.trim(),
                      authorId: currentUser.id.toString(),
                      authorName: currentUser.displayName,
                      groupId: widget.groupId,
                    );
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}