import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/carbon_entry_model.dart';
import '../models/product_model.dart';
import '../models/challenge_model.dart';
import '../models/forum_post_model.dart';
import '../core/constants.dart';

class DatabaseService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<CarbonEntryModel> _carbonEntries = [];
  final List<ProductModel> _products = [];
  final List<ChallengeModel> _challenges = [];
  final List<UserChallengeModel> _userChallenges = [];
  final List<ForumPostModel> _forumPosts = [];
  final List<CommentModel> _comments = [];

  bool _isInitialized = false;

  List<CarbonEntryModel> get carbonEntries => List.unmodifiable(_carbonEntries);
  List<ProductModel> get products => List.unmodifiable(_products);
  List<ChallengeModel> get challenges => List.unmodifiable(_challenges);
  List<UserChallengeModel> get userChallenges => List.unmodifiable(_userChallenges);
  List<ForumPostModel> get forumPosts => List.unmodifiable(_forumPosts);
  List<CommentModel> get comments => List.unmodifiable(_comments);

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _seedData();
    _isInitialized = true;
    notifyListeners();
  }

  // Carbon Entries
  Future<void> addCarbonEntry(CarbonEntryModel entry) async {
    _carbonEntries.add(entry);
    notifyListeners();
    // Fire-and-forget persist to Firestore
    unawaited(_db.collection('carbonEntries').doc(entry.id).set(entry.toJson()));
  }

  List<CarbonEntryModel> getCarbonEntriesForUser(String userId) {
    return _carbonEntries.where((entry) => entry.userId == userId).toList();
  }

  List<CarbonEntryModel> getCarbonEntriesForDateRange(String userId, DateTime start, DateTime end) {
    // Inclusive range: start <= entry.date <= end
    return _carbonEntries.where((entry) => 
        entry.userId == userId &&
        !entry.date.isBefore(start) &&
        !entry.date.isAfter(end)
    ).toList();
  }

  double getWeeklyCarbonSavings(String userId) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    
    final weekEntries = getCarbonEntriesForDateRange(userId, weekStart, weekEnd);
    final totalCO2 = weekEntries.fold<double>(0, (sum, entry) => sum + entry.co2eKg);
    
    // Calculate savings based on average emissions (positive values are savings)
    const averageWeeklyCO2 = 150.0; // kg CO2e per week for average person
    return math.max(0, averageWeeklyCO2 - totalCO2.abs());
  }

  // Products
  List<ProductModel> searchProducts(String query, {String? category, int? minEcoScore}) {
    return _products.where((product) {
      final matchesQuery = query.isEmpty || 
          product.title.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase()) ||
          product.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
      
      final matchesCategory = category == null || product.category == category;
      final matchesEcoScore = minEcoScore == null || product.ecoScore >= minEcoScore;
      
      return matchesQuery && matchesCategory && matchesEcoScore;
    }).toList();
  }

  // Challenges
  Future<void> startChallenge(String userId, String challengeId) async {
    final userChallenge = UserChallengeModel(
      id: 'uc_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      challengeId: challengeId,
      startedAt: DateTime.now(),
      status: 'active',
    );
    _userChallenges.add(userChallenge);
    notifyListeners();
    unawaited(_db.collection('userChallenges').doc(userChallenge.id).set(userChallenge.toJson()));
  }

  Future<void> completeChallenge(String userId, String challengeId) async {
    final index = _userChallenges.indexWhere(
      (uc) => uc.userId == userId && uc.challengeId == challengeId && uc.isActive
    );
    
    if (index != -1) {
      final updated = UserChallengeModel(
        id: _userChallenges[index].id,
        userId: userId,
        challengeId: challengeId,
        startedAt: _userChallenges[index].startedAt,
        completedAt: DateTime.now(),
        status: 'completed',
        progress: 100,
      );
      _userChallenges[index] = updated;
      notifyListeners();
      unawaited(_db.collection('userChallenges').doc(updated.id).update(updated.toJson()));
    }
  }

  List<UserChallengeModel> getUserChallenges(String userId) {
    return _userChallenges.where((uc) => uc.userId == userId).toList();
  }

  // Forum
  Future<void> addForumPost(ForumPostModel post) async {
    _forumPosts.add(post);
    notifyListeners();
    unawaited(_db.collection('forumPosts').doc(post.id).set(post.toJson()));
  }

  Future<void> likePost(String postId) async {
    final index = _forumPosts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      _forumPosts[index] = _forumPosts[index].copyWith(likes: _forumPosts[index].likes + 1);
      notifyListeners();
      unawaited(_db.collection('forumPosts').doc(postId).update({'likes': _forumPosts[index].likes}));
    }
  }

  Future<void> addComment(CommentModel comment) async {
    _comments.add(comment);
    notifyListeners();
    unawaited(_db.collection('comments').doc(comment.id).set(comment.toJson()));
  }

  List<CommentModel> getCommentsForPost(String postId) {
    return _comments.where((comment) => comment.postId == postId).toList();
  }

  Future<void> _seedData() async {
    // Seed products
    _products.addAll([
      const ProductModel(
        id: 'prod_1',
        title: 'Bamboo Toothbrush Set',
        description: 'Eco-friendly bamboo toothbrushes with biodegradable bristles. Perfect for reducing plastic waste in your daily routine.',
        price: 15.99,
        ecoScore: 95,
        tags: ['bamboo', 'biodegradable', 'plastic-free'],
        imageUrl: 'https://images.unsplash.com/photo-1556228578-626416bd4156?q=80&w=1000&auto=format&fit=crop',
        supplierUrl: 'https://example.com/bamboo-toothbrush',
        rating: 4.8,
        category: 'personal_care',
      ),
      const ProductModel(
        id: 'prod_2',
        title: 'Reusable Water Bottle',
        description: 'Stainless steel water bottle that keeps drinks cold for 24 hours and hot for 12 hours. BPA-free and leak-proof.',
        price: 28.99,
        ecoScore: 92,
        tags: ['stainless-steel', 'reusable', 'bpa-free'],
        imageUrl: 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?q=80&w=1000&auto=format&fit=crop',
        supplierUrl: 'https://example.com/water-bottle',
        rating: 4.9,
        category: 'kitchen',
      ),
      const ProductModel(
        id: 'prod_3',
        title: 'Organic Cotton Tote Bag',
        description: 'Durable organic cotton tote bag perfect for grocery shopping. Replaces hundreds of plastic bags.',
        price: 12.99,
        ecoScore: 88,
        tags: ['organic-cotton', 'reusable', 'shopping'],
        imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?q=80&w=1000&auto=format&fit=crop',
        supplierUrl: 'https://example.com/tote-bag',
        rating: 4.6,
        category: 'bags',
      ),
      const ProductModel(
        id: 'prod_4',
        title: 'Solar Power Bank',
        description: 'Portable solar power bank with 20,000mAh capacity. Charge your devices using clean solar energy.',
        price: 45.99,
        ecoScore: 90,
        tags: ['solar', 'renewable', 'portable'],
        imageUrl: 'https://images.unsplash.com/photo-1593114825229-0c6d819e3c0e?q=80&w=1000&auto=format&fit=crop',
        supplierUrl: 'https://example.com/solar-power-bank',
        rating: 4.7,
        category: 'electronics',
      ),
      const ProductModel(
        id: 'prod_5',
        title: 'Compost Bin',
        description: 'Kitchen compost bin with charcoal filter to eliminate odors. Turn food scraps into nutrient-rich compost.',
        price: 35.99,
        ecoScore: 94,
        tags: ['composting', 'recycling', 'odor-free'],
        imageUrl: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?q=80&w=1000&auto=format&fit=crop',
        supplierUrl: 'https://example.com/compost-bin',
        rating: 4.5,
        category: 'home',
      ),
    ]);

    // Seed challenges
    _challenges.addAll([
      const ChallengeModel(
        id: 'challenge_1',
        title: 'Plastic-Free Week',
        description: 'Avoid single-use plastics for an entire week. Use reusable alternatives instead.',
        frequency: 'weekly',
        rewardPoints: 50,
        category: 'waste',
        difficulty: 'medium',
        tips: [
          'Bring your own water bottle',
          'Use reusable shopping bags',
          'Choose products with minimal packaging',
          'Say no to plastic straws and utensils',
        ],
        imageUrl: 'https://images.unsplash.com/photo-1583258292688-d0213dc5a3a8?q=80&w=1000&auto=format&fit=crop',
      ),
      const ChallengeModel(
        id: 'challenge_2',
        title: 'Walk or Bike to Work',
        description: 'Choose walking or biking over driving for your daily commute this week.',
        frequency: 'weekly',
        rewardPoints: 40,
        category: 'transport',
        difficulty: 'easy',
        tips: [
          'Plan your route in advance',
          'Check the weather forecast',
          'Start with shorter distances',
          'Combine with public transport if needed',
        ],
        imageUrl: 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?q=80&w=1000&auto=format&fit=crop',
      ),
      const ChallengeModel(
        id: 'challenge_3',
        title: 'Meatless Monday Month',
        description: 'Go vegetarian every Monday for a month to reduce your food carbon footprint.',
        frequency: 'monthly',
        rewardPoints: 80,
        category: 'food',
        difficulty: 'easy',
        tips: [
          'Explore new vegetarian recipes',
          'Try plant-based protein sources',
          'Visit vegetarian restaurants',
          'Share meals with friends and family',
        ],
        imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=1000&auto=format&fit=crop',
      ),
      const ChallengeModel(
        id: 'challenge_4',
        title: 'Energy Saver Week',
        description: 'Reduce your home energy consumption by 20% this week through conscious choices.',
        frequency: 'weekly',
        rewardPoints: 60,
        category: 'energy',
        difficulty: 'medium',
        tips: [
          'Unplug electronics when not in use',
          'Use LED light bulbs',
          'Set thermostat 2 degrees lower/higher',
          'Air dry clothes instead of using dryer',
        ],
        imageUrl: 'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?q=80&w=1000&auto=format&fit=crop',
      ),
      const ChallengeModel(
        id: 'challenge_5',
        title: 'Zero Food Waste Week',
        description: 'Plan meals carefully and use all food items to achieve zero food waste.',
        frequency: 'weekly',
        rewardPoints: 70,
        category: 'food',
        difficulty: 'hard',
        tips: [
          'Plan your meals in advance',
          'Store food properly to extend freshness',
          'Use leftovers creatively',
          'Compost unavoidable scraps',
        ],
        imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=1000&auto=format&fit=crop',
      ),
    ]);

    // Seed demo carbon entries for demo user
    final random = math.Random();
    final now = DateTime.now();
    
    for (int i = 0; i < 14; i++) {
      final date = now.subtract(Duration(days: i));
      
      // Add transport entry
      _carbonEntries.add(CarbonEntryModel(
        id: 'entry_transport_$i',
        userId: 'user_123',
        date: date,
        category: 'transport',
        subType: ['car_km', 'bus_km', 'train_km', 'bike_km'][random.nextInt(4)],
        quantity: 5 + random.nextDouble() * 20,
        unit: 'km',
        co2eKg: 0,
      ));
      
      // Add energy entry
      _carbonEntries.add(CarbonEntryModel(
        id: 'entry_energy_$i',
        userId: 'user_123',
        date: date,
        category: 'energy',
        subType: 'electricity_kwh',
        quantity: 8 + random.nextDouble() * 12,
        unit: 'kWh',
        co2eKg: 0,
      ));
      
      // Add food entry
      _carbonEntries.add(CarbonEntryModel(
        id: 'entry_food_$i',
        userId: 'user_123',
        date: date,
        category: 'food',
        subType: ['beef_serving', 'chicken_serving', 'vegetarian_meal', 'vegan_meal'][random.nextInt(4)],
        quantity: 1 + random.nextInt(3).toDouble(),
        unit: 'servings',
        co2eKg: 0,
      ));
    }

    // Calculate CO2 for all entries
    for (int i = 0; i < _carbonEntries.length; i++) {
      final entry = _carbonEntries[i];
      final emissionFactor = AppConstants.emissionFactors[entry.subType] ?? 0.0;
      _carbonEntries[i] = entry.copyWith(co2eKg: entry.quantity * emissionFactor);
    }

    // Seed forum posts
    _forumPosts.addAll([
      ForumPostModel(
        id: 'post_1',
        userId: 'user_123',
        authorName: 'Demo User',
        authorImageUrl: 'https://ui-avatars.com/api/?name=Demo+User&size=200&background=2E7D32&color=fff',
        title: 'My First Week Going Plastic-Free!',
        body: 'Just completed my first plastic-free week challenge! It was harder than I expected, but I learned so many alternatives. The bamboo toothbrush is amazing!',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 15,
        tags: ['plastic-free', 'challenge', 'beginner'],
        category: 'success-story',
      ),
      ForumPostModel(
        id: 'post_2',
        userId: 'user_456',
        authorName: 'Sarah Green',
        authorImageUrl: 'https://ui-avatars.com/api/?name=Sarah+Green&size=200&background=4CAF50&color=fff',
        title: 'Best Composting Tips for Beginners',
        body: 'After 6 months of composting, here are my top tips: 1) Keep a good brown/green ratio, 2) Turn regularly, 3) Keep it moist but not wet. What are your experiences?',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likes: 28,
        tags: ['composting', 'tips', 'beginner'],
        category: 'tips',
      ),
      ForumPostModel(
        id: 'post_3',
        userId: 'user_789',
        authorName: 'Alex River',
        authorImageUrl: 'https://ui-avatars.com/api/?name=Alex+River&size=200&background=FF9800&color=fff',
        title: 'Solar Panels Installation Experience',
        body: 'Just installed solar panels on my roof last month. The process was smoother than expected and I\'m already seeing savings on my electricity bill!',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        likes: 42,
        tags: ['solar', 'renewable-energy', 'home-improvement'],
        category: 'experience',
      ),
    ]);

    // Seed some comments
    _comments.addAll([
      CommentModel(
        id: 'comment_1',
        postId: 'post_1',
        userId: 'user_456',
        authorName: 'Sarah Green',
        authorImageUrl: 'https://ui-avatars.com/api/?name=Sarah+Green&size=200&background=4CAF50&color=fff',
        body: 'Congratulations on completing the challenge! The first week is always the hardest.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        likes: 5,
      ),
      CommentModel(
        id: 'comment_2',
        postId: 'post_2',
        userId: 'user_123',
        authorName: 'Demo User',
        authorImageUrl: 'https://ui-avatars.com/api/?name=Demo+User&size=200&background=2E7D32&color=fff',
        body: 'Great tips! I just started composting and this is really helpful.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        likes: 3,
      ),
    ]);
  }
}
