class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final UserPreferences preferences;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    required this.preferences,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'preferences': preferences.toJson(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
    );
  }

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    UserPreferences? preferences,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
    );
  }
}

class UserPreferences {
  final String textSize;
  final bool accessibilityMode;
  final bool darkMode;
  final bool notifications;
  final String language;

  const UserPreferences({
    this.textSize = 'normal',
    this.accessibilityMode = false,
    this.darkMode = false,
    this.notifications = true,
    this.language = 'en',
  });

  Map<String, dynamic> toJson() {
    return {
      'textSize': textSize,
      'accessibilityMode': accessibilityMode,
      'darkMode': darkMode,
      'notifications': notifications,
      'language': language,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      textSize: json['textSize'] ?? 'normal',
      accessibilityMode: json['accessibilityMode'] ?? false,
      darkMode: json['darkMode'] ?? false,
      notifications: json['notifications'] ?? true,
      language: json['language'] ?? 'en',
    );
  }

  UserPreferences copyWith({
    String? textSize,
    bool? accessibilityMode,
    bool? darkMode,
    bool? notifications,
    String? language,
  }) {
    return UserPreferences(
      textSize: textSize ?? this.textSize,
      accessibilityMode: accessibilityMode ?? this.accessibilityMode,
      darkMode: darkMode ?? this.darkMode,
      notifications: notifications ?? this.notifications,
      language: language ?? this.language,
    );
  }
}

