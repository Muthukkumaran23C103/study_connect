import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/providers/post_provider.dart';
import '../../core/providers/study_group_provider.dart';
import '../../core/models/post_model.dart';

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
        context.read<PostProvider>().loadAllPosts();
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
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          if (postProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (postProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${postProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
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

          final posts = postProvider.posts;

          if (posts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No posts yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create your first post to get started!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              if (widget.groupId != null) {
                return postProvider.loadGroupPosts(widget.groupId!);
              } else {
                return postProvider.loadAllPosts();
              }
            },
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue,
                  child: Text(
                    post.authorName.isNotEmpty
                        ? post.authorName.substring(0, 1).toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatTime(post.createdAt),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handlePostAction(context, post, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'save',
                      child: Row(
                        children: [
                          Icon(Icons.bookmark_outline),
                          SizedBox(width: 8),
                          Text('Save'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.report_outline),
                          SizedBox(width: 8),
                          Text('Report'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Post title
            if (post.title.isNotEmpty)
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

            if (post.title.isNotEmpty) const SizedBox(height: 8),

            // Post content
            Text(
              post.content,
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: post.isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: () => _toggleLike(context, post),
                ),
                Text('${post.likeCount}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.comment_outlined, color: Colors.grey),
                  onPressed: () => _showComments(context, post),
                ),
                Text('${post.commentCount}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.share_outlined, color: Colors.grey),
                  onPressed: () => _sharePost(context, post),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return DateFormat('MMM dd, yyyy').format(timestamp);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _toggleLike(BuildContext context, Post post) {
    // Implement like functionality
    context.read<PostProvider>().toggleLike(post.id!);
  }

  void _showComments(BuildContext context, Post post) {
    // Implement comments view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comments feature coming soon!')),
    );
  }

  void _sharePost(BuildContext context, Post post) {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon!')),
    );
  }

  void _handlePostAction(BuildContext context, Post post, String action) {
    switch (action) {
      case 'save':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post saved!')),
        );
        break;
      case 'report':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post reported!')),
        );
        break;
    }
  }

  void _showCreatePostDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    int? selectedGroupId = widget.groupId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Post'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.groupId == null)
                Consumer<StudyGroupProvider>(
                  builder: (context, groupProvider, child) {
                    return DropdownButtonFormField<int>(
                      value: selectedGroupId,
                      decoration: const InputDecoration(labelText: 'Group'),
                      hint: const Text('Select a group'),
                      items: groupProvider.userGroups.map((group) {
                        return DropdownMenuItem(
                          value: group.id,
                          child: Text(group.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedGroupId = value;
                      },
                    );
                  },
                ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title (Optional)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (contentController.text.isNotEmpty && selectedGroupId != null) {
                try {
                  await context.read<PostProvider>().createPost(
                    groupId: selectedGroupId!,
                    title: titleController.text,
                    content: contentController.text,
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post created successfully!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create post: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Posts'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Search by title or content',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (query) {
            if (query.isNotEmpty) {
              context.read<PostProvider>().searchPosts(query);
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final query = searchController.text;
              if (query.isNotEmpty) {
                context.read<PostProvider>().searchPosts(query);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}
