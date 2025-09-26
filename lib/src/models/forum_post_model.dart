class ForumPostModel {
  final String id;
  final String userId;
  final String authorName;
  final String? authorImageUrl;
  final String title;
  final String body;
  final DateTime createdAt;
  final List<String> images;
  final int likes;
  final int flags;
  final List<String> tags;
  final String category;

  const ForumPostModel({
    required this.id,
    required this.userId,
    required this.authorName,
    this.authorImageUrl,
    required this.title,
    required this.body,
    required this.createdAt,
    this.images = const [],
    this.likes = 0,
    this.flags = 0,
    this.tags = const [],
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'authorName': authorName,
      'authorImageUrl': authorImageUrl,
      'title': title,
      'body': body,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'images': images,
      'likes': likes,
      'flags': flags,
      'tags': tags,
      'category': category,
    };
  }

  factory ForumPostModel.fromJson(Map<String, dynamic> json) {
    return ForumPostModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      authorName: json['authorName'] ?? '',
      authorImageUrl: json['authorImageUrl'],
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      images: List<String>.from(json['images'] ?? []),
      likes: json['likes'] ?? 0,
      flags: json['flags'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'] ?? '',
    );
  }

  ForumPostModel copyWith({
    String? id,
    String? userId,
    String? authorName,
    String? authorImageUrl,
    String? title,
    String? body,
    DateTime? createdAt,
    List<String>? images,
    int? likes,
    int? flags,
    List<String>? tags,
    String? category,
  }) {
    return ForumPostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      authorImageUrl: authorImageUrl ?? this.authorImageUrl,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      images: images ?? this.images,
      likes: likes ?? this.likes,
      flags: flags ?? this.flags,
      tags: tags ?? this.tags,
      category: category ?? this.category,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String authorName;
  final String? authorImageUrl;
  final String body;
  final DateTime createdAt;
  final int likes;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.authorName,
    this.authorImageUrl,
    required this.body,
    required this.createdAt,
    this.likes = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'authorName': authorName,
      'authorImageUrl': authorImageUrl,
      'body': body,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'likes': likes,
    };
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      authorName: json['authorName'] ?? '',
      authorImageUrl: json['authorImageUrl'],
      body: json['body'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      likes: json['likes'] ?? 0,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
