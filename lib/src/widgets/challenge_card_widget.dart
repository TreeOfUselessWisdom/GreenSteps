import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/challenge_model.dart';

class ChallengeCardWidget extends StatelessWidget {
  final ChallengeModel challenge;
  final UserChallengeModel? userChallenge;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;

  const ChallengeCardWidget({
    super.key,
    required this.challenge,
    this.userChallenge,
    this.onStart,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = userChallenge?.isCompleted ?? false;
    final isActive = userChallenge?.isActive ?? false;

    return Container(
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
          // Challenge Image
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: challenge.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.flag,
                    color: Colors.grey[400],
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          
          // Challenge Info
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    challenge.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Description
                  Expanded(
                    child: Text(
                      challenge.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Frequency and Points
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(challenge.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          challenge.frequency,
                          style: TextStyle(
                            color: _getCategoryColor(challenge.category),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.stars, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${challenge.rewardPoints} pts',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: _buildActionButton(context, isCompleted, isActive),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, bool isCompleted, bool isActive) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
            SizedBox(width: 8),
            Text(
              'Completed',
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    
    if (isActive) {
      return ElevatedButton(
        onPressed: onComplete,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
        ),
        child: const Text('Mark Complete'),
      );
    }
    
    return ElevatedButton(
      onPressed: onStart,
      child: const Text('Start Challenge'),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'transport':
        return const Color(0xFF2196F3);
      case 'energy':
        return const Color(0xFFFF9800);
      case 'food':
        return const Color(0xFF4CAF50);
      case 'waste':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF2E7D32);
    }
  }
}
