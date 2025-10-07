import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/post_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class PostFeedScreen extends StatefulWidget {
  final int? groupId;

  const PostFeedScreen({super.key, this.groupId});

  @override
  State<PostFeedScreen> createState() => _PostFeedScreenState();
}

class _PostFeedScreenState extends State<PostFeedScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

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
      appBar: AppBar(
        title: Text(widget.groupId != null ? 'Group Posts' : 'All Posts'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Error handling
          Consumer<PostProvider>(
            builder: (context, postProvider, child) {
              if (postProvider.errorMessage != null) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    'Error: ${postProvider.errorMessage}',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Refresh button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<PostProvider>(
              builder: (context, postProvider, child) {
                return ElevatedButton(
                  onPressed: postProvider.isLoading ? null : () {
                    if (widget.groupId != null) {
                      postProvider.loadGroupPosts(widget.groupId!);
                    } else {
                      postProvider.loadAllPosts();
                    }
                  },
                  child: postProvider.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Refresh Posts'),
                );
              },
            ),
          ),

          // Posts list
          Expanded(
            child: Consumer<PostProvider>(
              builder: (context, postProvider, child) {
                if (postProvider.isLoading && postProvider.posts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (postProvider.posts.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.post_add, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Be the first to share something!',
                          style: TextStyle(color: Colors.grey),
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
                  child: ListView.builder(
                    itemCount: postProvider.posts.length,
                    itemBuilder: (context, index) {
                      final post = postProvider.posts[index];
                      return _buildPostCard(post);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostCard(post) {
    final currentUser = context.read<AuthProvider>().currentUser;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  child: Text(post.authorName.substring(0, 1).toUpperCase()),
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
                        _formatDate(post.timestamp),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'report') {
                      _showReportDialog();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.report_outlined),
                          SizedBox(width: 8),
                          Text('Report'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Content
            Text(post.content),
            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                TextButton.icon(
                  onPressed: currentUser != null ? () {
                    context.read<PostProvider>().toggleLike(
                      post.id!,
                      currentUser.id.toString(),
                    );
                  } : null,
                  icon: const Icon(Icons.thumb_up_outlined),
                  label: Text('${post.likesCount} Likes'),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Implement comments
                  },
                  icon: const Icon(Icons.comment_outlined),
                  label: Text('${post.commentsCount} Comments'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePostDialog() {
    final currentUser = context.read<AuthProvider>().currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to create posts')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Post'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Enter post title',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _contentController,
                label: 'Content',
                hint: 'What would you like to share?',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          Consumer<PostProvider>(
            builder: (context, postProvider, child) {
              return ElevatedButton(
                onPressed: postProvider.isLoading ? null : () async {
                  if (_titleController.text.trim().isEmpty ||
                      _contentController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  await context.read<PostProvider>().createPost(
                    authorId: currentUser.id.toString(),
                    authorName: currentUser.displayName,
                    title: _titleController.text.trim(),
                    content: _contentController.text.trim(),
                    groupId: widget.groupId,
                  );

                  _titleController.clear();
                  _contentController.clear();
                  Navigator.of(context).pop();
                },
                child: postProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Post'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: const Text('This feature is not implemented yet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
