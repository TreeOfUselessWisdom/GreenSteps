import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/challenge_card_widget.dart';
import '../widgets/responsive_grid_widget.dart';
import '../models/challenge_model.dart';
import '../core/responsive_layout.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'all';
  String _selectedFrequency = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Sustainability Challenges'),
      body: Column(
        children: [
          Container(
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
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Available', icon: Icon(Icons.flag_outlined)),
                Tab(text: 'My Challenges', icon: Icon(Icons.assignment)),
                Tab(text: 'Completed', icon: Icon(Icons.check_circle_outline)),
              ],
            ),
          ),
          _buildFilters(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAvailableChallenges(),
                _buildMyChallenges(),
                _buildCompletedChallenges(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: ResponsiveLayout.getPadding(context).copyWith(top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Category', _selectedCategory, _showCategoryFilter),
            const SizedBox(width: 8),
            _buildFilterChip('Frequency', _selectedFrequency, _showFrequencyFilter),
            if (_selectedCategory != 'all' || _selectedFrequency != 'all') ...[
              const SizedBox(width: 8),
              ActionChip(
                label: const Text('Clear'),
                onPressed: () {
                  setState(() {
                    _selectedCategory = 'all';
                    _selectedFrequency = 'all';
                  });
                },
                backgroundColor: Colors.red.withOpacity(0.1),
                labelStyle: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, VoidCallback onTap) {
    final isActive = value != 'all';
    return FilterChip(
      label: Text('$label${isActive ? ': ${_formatFilterValue(value)}' : ''}'),
      selected: isActive,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey[100],
      selectedColor: const Color(0xFF4CAF50).withOpacity(0.2),
      checkmarkColor: const Color(0xFF2E7D32),
    );
  }

  Widget _buildAvailableChallenges() {
    return Consumer2<AuthService, DatabaseService>(
      builder: (context, authService, databaseService, child) {
        final user = authService.currentUser;
        if (user == null) return const Center(child: Text('Please log in to view challenges'));

        final allChallenges = databaseService.challenges;
        final userChallenges = databaseService.getUserChallenges(user.uid);
        final userChallengeIds = userChallenges.map((uc) => uc.challengeId).toSet();
        
        // Filter available challenges (not started or completed)
        final availableChallenges = allChallenges.where((challenge) =>
          !userChallengeIds.contains(challenge.id) &&
          _matchesFilters(challenge)
        ).toList();

        if (availableChallenges.isEmpty) {
          return _buildEmptyState(
            Icons.flag_outlined,
            'No Available Challenges',
            _selectedCategory != 'all' || _selectedFrequency != 'all'
                ? 'Try adjusting your filters'
                : 'All challenges have been started',
          );
        }

        return SingleChildScrollView(
          padding: ResponsiveLayout.getPadding(context).copyWith(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${availableChallenges.length} challenge${availableChallenges.length != 1 ? 's' : ''} available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              ResponsiveGridWidget(
                children: availableChallenges.map((challenge) =>
                  ChallengeCardWidget(
                    challenge: challenge,
                    userChallenge: null,
                    onStart: () => _startChallenge(challenge.id),
                    onComplete: null,
                  ),
                ).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyChallenges() {
    return Consumer2<AuthService, DatabaseService>(
      builder: (context, authService, databaseService, child) {
        final user = authService.currentUser;
        if (user == null) return const Center(child: Text('Please log in to view challenges'));

        final allChallenges = databaseService.challenges;
        final userChallenges = databaseService.getUserChallenges(user.uid)
            .where((uc) => uc.isActive)
            .toList();

        if (userChallenges.isEmpty) {
          return _buildEmptyState(
            Icons.assignment_outlined,
            'No Active Challenges',
            'Start some challenges from the Available tab',
          );
        }

        // Filter active challenges
        final activeChallenges = <Widget>[];
        for (final userChallenge in userChallenges) {
          final challenge = allChallenges.firstWhere(
            (c) => c.id == userChallenge.challengeId,
            orElse: () => allChallenges.first,
          );
          
          if (_matchesFilters(challenge)) {
            activeChallenges.add(
              ChallengeCardWidget(
                challenge: challenge,
                userChallenge: userChallenge,
                onStart: null,
                onComplete: () => _completeChallenge(userChallenge.challengeId),
              ),
            );
          }
        }

        if (activeChallenges.isEmpty) {
          return _buildEmptyState(
            Icons.filter_list,
            'No Matches',
            'Try adjusting your filters',
          );
        }

        return SingleChildScrollView(
          padding: ResponsiveLayout.getPadding(context).copyWith(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${activeChallenges.length} active challenge${activeChallenges.length != 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              ResponsiveGridWidget(children: activeChallenges),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompletedChallenges() {
    return Consumer2<AuthService, DatabaseService>(
      builder: (context, authService, databaseService, child) {
        final user = authService.currentUser;
        if (user == null) return const Center(child: Text('Please log in to view challenges'));

        final allChallenges = databaseService.challenges;
        final completedUserChallenges = databaseService.getUserChallenges(user.uid)
            .where((uc) => uc.isCompleted)
            .toList();

        if (completedUserChallenges.isEmpty) {
          return _buildEmptyState(
            Icons.check_circle_outline,
            'No Completed Challenges',
            'Complete some challenges to see them here',
          );
        }

        // Sort by completion date (most recent first)
        completedUserChallenges.sort((a, b) => 
          (b.completedAt ?? DateTime.now()).compareTo(a.completedAt ?? DateTime.now()));

        // Filter completed challenges
        final completedChallenges = <Widget>[];
        for (final userChallenge in completedUserChallenges) {
          final challenge = allChallenges.firstWhere(
            (c) => c.id == userChallenge.challengeId,
            orElse: () => allChallenges.first,
          );
          
          if (_matchesFilters(challenge)) {
            completedChallenges.add(
              ChallengeCardWidget(
                challenge: challenge,
                userChallenge: userChallenge,
                onStart: null,
                onComplete: null,
              ),
            );
          }
        }

        if (completedChallenges.isEmpty) {
          return _buildEmptyState(
            Icons.filter_list,
            'No Matches',
            'Try adjusting your filters',
          );
        }

        return SingleChildScrollView(
          padding: ResponsiveLayout.getPadding(context).copyWith(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${completedChallenges.length} completed challenge${completedChallenges.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_getTotalPoints(completedUserChallenges, allChallenges)} pts earned',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ResponsiveGridWidget(children: completedChallenges),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCategoryFilter() {
    final categories = ['all', 'transport', 'energy', 'food', 'waste'];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter by Category',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      ...categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return ListTile(
                          title: Text(_formatFilterValue(category)),
                          leading: isSelected 
                              ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                              : const SizedBox(width: 24),
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                            Navigator.pop(context);
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFrequencyFilter() {
    final frequencies = ['all', 'daily', 'weekly', 'monthly'];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter by Frequency',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      ...frequencies.map((frequency) {
                        final isSelected = _selectedFrequency == frequency;
                        return ListTile(
                          title: Text(_formatFilterValue(frequency)),
                          leading: isSelected 
                              ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                              : const SizedBox(width: 24),
                          onTap: () {
                            setState(() {
                              _selectedFrequency = frequency;
                            });
                            Navigator.pop(context);
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _matchesFilters(ChallengeModel challenge) {
    final matchesCategory = _selectedCategory == 'all' || challenge.category == _selectedCategory;
    final matchesFrequency = _selectedFrequency == 'all' || challenge.frequency == _selectedFrequency;
    return matchesCategory && matchesFrequency;
  }

  String _formatFilterValue(String value) {
    if (value == 'all') return 'All';
    return value[0].toUpperCase() + value.substring(1);
  }

  int _getTotalPoints(List<UserChallengeModel> userChallenges, List<ChallengeModel> allChallenges) {
    int totalPoints = 0;
    for (final userChallenge in userChallenges) {
      final challenge = allChallenges.firstWhere(
        (c) => c.id == userChallenge.challengeId,
        orElse: () => allChallenges.first,
      );
      totalPoints += challenge.rewardPoints;
    }
    return totalPoints;
  }

  Future<void> _startChallenge(String challengeId) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    
    final user = authService.currentUser;
    if (user == null) return;

    try {
      await databaseService.startChallenge(user.uid, challengeId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Challenge started! Good luck!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        
        // Switch to My Challenges tab
        _tabController.animateTo(1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting challenge: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeChallenge(String challengeId) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    
    final user = authService.currentUser;
    if (user == null) return;

    try {
      await databaseService.completeChallenge(user.uid, challengeId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Congratulations! Challenge completed! 🎉'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing challenge: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
