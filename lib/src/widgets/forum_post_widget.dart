import 'package:flutter/material.dart';
import '../models/forum_post_model.dart';

class ForumPostWidget extends StatelessWidget {
  final ForumPostModel post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onFlag;

  const ForumPostWidget({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onFlag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: post.authorImageUrl != null
                    ? NetworkImage(post.authorImageUrl!)
                    : null,
                backgroundColor: const Color(0xFF4CAF50),
                child: post.authorImageUrl == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      post.timeAgo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _buildCategoryChip(post.category),
            ],
          ),
          const SizedBox(height: 16),
          
          // Post Title
          Text(
            post.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Post Body
          Text(
            post.body,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Tags
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: post.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#$tag',
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 12,
                  ),
                ),
              )).toList(),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              _buildActionButton(
                icon: Icons.thumb_up_outlined,
                label: '${post.likes}',
                onTap: onLike,
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: Icons.comment_outlined,
                label: 'Comment',
                onTap: onComment,
              ),
              const Spacer(),
              _buildActionButton(
                icon: Icons.flag_outlined,
                label: 'Flag',
                onTap: onFlag,
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getCategoryColor(category).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatCategory(category),
        style: TextStyle(
          color: _getCategoryColor(category),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: color ?? const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color ?? const Color(0xFF2E7D32),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'tips':
        return const Color(0xFF2196F3);
      case 'success-story':
        return const Color(0xFF4CAF50);
      case 'question':
        return const Color(0xFFFF9800);
      case 'experience':
        return const Color(0xFF9C27B0);
      case 'product-review':
        return const Color(0xFF607D8B);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  String _formatCategory(String category) {
    switch (category) {
      case 'success-story':
        return 'Success';
      case 'product-review':
        return 'Review';
      default:
        return category[0].toUpperCase() + category.substring(1);
    }
  }
}
