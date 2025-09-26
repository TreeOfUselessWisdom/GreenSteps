import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/forum_post_widget.dart';
import '../models/forum_post_model.dart';
import '../core/responsive_layout.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final _postTitleController = TextEditingController();
  final _postBodyController = TextEditingController();
  String _selectedCategory = 'tips';
  bool _isCreatingPost = false;

  @override
  void dispose() {
    _postTitleController.dispose();
    _postBodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Community Forum'),
      body: Consumer2<AuthService, DatabaseService>(
        builder: (context, authService, databaseService, child) {
          final user = authService.currentUser;
          final posts = databaseService.forumPosts;
          
          // Sort posts by creation date (newest first)
          final sortedPosts = List<ForumPostModel>.from(posts)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return Column(
            children: [
              if (user != null) _buildCreatePostButton(),
              Expanded(
                child: sortedPosts.isEmpty
                    ? _buildEmptyState()
                    : _buildPostsList(sortedPosts),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCreatePostButton() {
    return Container(
      padding: ResponsiveLayout.getPadding(context).copyWith(top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _showCreatePostDialog,
          icon: const Icon(Icons.add),
          label: const Text('Share Your Eco Journey'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildPostsList(List<ForumPostModel> posts) {
    return ListView.builder(
      padding: ResponsiveLayout.getPadding(context).copyWith(top: 8),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ForumPostWidget(
            post: posts[index],
            onLike: () => _likePost(posts[index].id),
            onComment: () => _showCommentsDialog(posts[index]),
            onFlag: () => _flagPost(posts[index].id),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome to the Community!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Share your sustainable living tips, achievements, and connect with like-minded people',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreatePostDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Your First Post'),
          ),
        ],
      ),
    );
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Post'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Selection
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(value: 'tips', child: Text('Tips & Advice')),
                  DropdownMenuItem(value: 'success-story', child: Text('Success Story')),
                  DropdownMenuItem(value: 'question', child: Text('Question')),
                  DropdownMenuItem(value: 'experience', child: Text('Experience')),
                  DropdownMenuItem(value: 'product-review', child: Text('Product Review')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Title Input
              TextField(
                controller: _postTitleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'What would you like to share?',
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 16),
              
              // Body Input
              TextField(
                controller: _postBodyController,
                decoration: const InputDecoration(
                  labelText: 'Your Story',
                  hintText: 'Share your thoughts, experiences, or tips...',
                ),
                maxLines: 6,
                maxLength: 1000,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearPostForm();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isCreatingPost ? null : _createPost,
            child: _isCreatingPost
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Post'),
          ),
        ],
      ),
    );
  }

  void _showCommentsDialog(ForumPostModel post) {
    final commentController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return Consumer<DatabaseService>(
              builder: (context, databaseService, child) {
                final comments = databaseService.getCommentsForPost(post.id);
                
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Comments (${comments.length})',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Comments List
                      Expanded(
                        child: comments.isEmpty
                            ? const Center(
                                child: Text(
                                  'No comments yet.\nBe the first to comment!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  final comment = comments[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 12,
                                              backgroundImage: comment.authorImageUrl != null
                                                  ? NetworkImage(comment.authorImageUrl!)
                                                  : null,
                                              backgroundColor: const Color(0xFF4CAF50),
                                              child: comment.authorImageUrl == null
                                                  ? const Icon(Icons.person, size: 12, color: Colors.white)
                                                  : null,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              comment.authorName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              comment.timeAgo,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(comment.body),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      
                      // Add Comment
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: const InputDecoration(
                                hintText: 'Add a comment...',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _addComment(post.id, commentController),
                            icon: const Icon(Icons.send),
                            color: const Color(0xFF4CAF50),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _createPost() async {
    if (_postTitleController.text.trim().isEmpty || _postBodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both title and content'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    
    final user = authService.currentUser;
    if (user == null) return;

    setState(() {
      _isCreatingPost = true;
    });

    try {
      final post = ForumPostModel(
        id: const Uuid().v4(),
        userId: user.uid,
        authorName: user.displayName,
        authorImageUrl: user.photoUrl,
        title: _postTitleController.text.trim(),
        body: _postBodyController.text.trim(),
        createdAt: DateTime.now(),
        category: _selectedCategory,
      );

      await databaseService.addForumPost(post);

      if (mounted) {
        Navigator.pop(context);
        _clearPostForm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingPost = false;
        });
      }
    }
  }

  Future<void> _likePost(String postId) async {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    try {
      await databaseService.likePost(postId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error liking post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addComment(String postId, TextEditingController controller) async {
    if (controller.text.trim().isEmpty) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    
    final user = authService.currentUser;
    if (user == null) return;

    try {
      final comment = CommentModel(
        id: const Uuid().v4(),
        postId: postId,
        userId: user.uid,
        authorName: user.displayName,
        authorImageUrl: user.photoUrl,
        body: controller.text.trim(),
        createdAt: DateTime.now(),
      );

      await databaseService.addComment(comment);
      controller.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added!'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _flagPost(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Flag Post'),
        content: const Text('Are you sure you want to flag this post as inappropriate?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post has been flagged for review'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Flag'),
          ),
        ],
      ),
    );
  }

  void _clearPostForm() {
    _postTitleController.clear();
    _postBodyController.clear();
    _selectedCategory = 'tips';
  }
}
