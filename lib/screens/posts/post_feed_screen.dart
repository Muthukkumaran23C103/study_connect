import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/post_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../core/models/post_model.dart';
import '../../core/models/user_model.dart';

class PostFeedScreen extends StatefulWidget {
  final int? groupId;

  const PostFeedScreen({super.key, this.groupId});

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
        context.read<PostProvider>().loadPosts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupId != null ? 'Group Posts' : 'All Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreatePostDialog(context),
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
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Error: ${postProvider.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.groupId != null) {
                        postProvider.loadGroupPosts(widget.groupId!);
                      } else {
                        postProvider.loadPosts();
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
                await postProvider.loadPosts();
              }
            },
            child: postProvider.posts.isEmpty
                ? const Center(child: Text('No posts yet'))
                : ListView.builder(
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

  Widget _buildPostCard(BuildContext context, PostModel post) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(post.authorName[0].toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatTime(post.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag),
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
            Text(post.content),
            const SizedBox(height: 16),
            Row(
              children: [
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final currentUser = authProvider.currentUser;
                    if (currentUser == null) return const SizedBox();

                    return IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        context.read<PostProvider>().toggleLike(post.id!, currentUser.id);
                      },
                    );
                  },
                ),
                Text('${post.likesCount} likes'),
                const SizedBox(width: 16),
                const Icon(Icons.comment, color: Colors.grey),
                Text(' ${post.commentsCount} comments'),
                const Spacer(),
                const Icon(Icons.share, color: Colors.grey),
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

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _reportPost(PostModel post) {
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
                const SnackBar(content: Text('Post reported successfully')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: contentController,
                label: 'Content',
                hintText: 'What would you like to share?',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.isNotEmpty) {
                  final currentUser = context.read<AuthProvider>().currentUser;
                  if (currentUser != null) {
                    final post = PostModel(
                      content: contentController.text.trim(),
                      authorId: currentUser.id,
                      authorName: currentUser.displayName,
                      groupId: widget.groupId,
                      createdAt: DateTime.now(),
                    );

                    await context.read<PostProvider>().createPost(post);
                    contentController.clear();
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }
}
