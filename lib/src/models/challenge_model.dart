class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final String frequency;
  final int rewardPoints;
  final String category;
  final String difficulty;
  final List<String> tips;
  final String imageUrl;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.frequency,
    required this.rewardPoints,
    required this.category,
    this.difficulty = 'medium',
    required this.tips,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'frequency': frequency,
      'rewardPoints': rewardPoints,
      'category': category,
      'difficulty': difficulty,
      'tips': tips,
      'imageUrl': imageUrl,
    };
  }

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      frequency: json['frequency'] ?? 'weekly',
      rewardPoints: json['rewardPoints'] ?? 0,
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? 'medium',
      tips: List<String>.from(json['tips'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  ChallengeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? frequency,
    int? rewardPoints,
    String? category,
    String? difficulty,
    List<String>? tips,
    String? imageUrl,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      tips: tips ?? this.tips,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class UserChallengeModel {
  final String id;
  final String userId;
  final String challengeId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String status;
  final int progress;

  const UserChallengeModel({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.startedAt,
    this.completedAt,
    this.status = 'active',
    this.progress = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'challengeId': challengeId,
      'startedAt': startedAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'status': status,
      'progress': progress,
    };
  }

  factory UserChallengeModel.fromJson(Map<String, dynamic> json) {
    return UserChallengeModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      challengeId: json['challengeId'] ?? '',
      startedAt: DateTime.fromMillisecondsSinceEpoch(json['startedAt'] ?? 0),
      completedAt: json['completedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'])
          : null,
      status: json['status'] ?? 'active',
      progress: json['progress'] ?? 0,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isActive => status == 'active';
}
