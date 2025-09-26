import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/custom_app_bar.dart';
import '../providers/app_providers.dart';
import '../core/responsive_layout.dart';
import '../core/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize name controller with current user name
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      _nameController.text = authService.currentUser?.displayName ?? '';
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Profile & Settings'),
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
                Tab(text: 'Profile', icon: Icon(Icons.person_outline)),
                Tab(text: 'Settings', icon: Icon(Icons.settings_outlined)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Consumer3<AuthService, DatabaseService, ThemeProvider>(
      builder: (context, authService, databaseService, themeProvider, child) {
        final user = authService.currentUser;
        if (user == null) {
          return const Center(child: Text('Please log in to view profile'));
        }

        final carbonEntries = databaseService.getCarbonEntriesForUser(user.uid);
        final userChallenges = databaseService.getUserChallenges(user.uid);
        final completedChallenges = userChallenges.where((uc) => uc.isCompleted).length;
        final weeklySavings = databaseService.getWeeklyCarbonSavings(user.uid);

        return SingleChildScrollView(
          padding: ResponsiveLayout.getPadding(context),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Profile Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          backgroundColor: Colors.white,
                          child: user.photoUrl == null
                              ? const Icon(Icons.person, size: 50, color: Color(0xFF2E7D32))
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Name editing
                    if (_isEditing) ...[
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _nameController.text = user.displayName;
                              });
                            },
                            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _saveName,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF2E7D32),
                            ),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = true;
                              });
                            },
                            icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'Member since ${_formatDate(user.createdAt)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Stats Section
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Entries Logged',
                      carbonEntries.length.toString(),
                      Icons.analytics,
                      const Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Challenges Done',
                      completedChallenges.toString(),
                      Icons.flag,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Weekly Savings',
                      '${weeklySavings.toStringAsFixed(1)} kg',
                      Icons.eco,
                      const Color(0xFF8BC34A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Impact Level',
                      _getImpactLevel(weeklySavings),
                      Icons.trending_up,
                      const Color(0xFFFF9800),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Actions Section
              _buildActionButton(
                'Share My Progress',
                Icons.share,
                () => _shareProgress(weeklySavings, completedChallenges, carbonEntries.length),
              ),
              
              const SizedBox(height: 12),
              
              _buildActionButton(
                'Export Data',
                Icons.download,
                () => _exportData(carbonEntries),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsTab() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SingleChildScrollView(
          padding: ResponsiveLayout.getPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Appearance Section
              Text(
                'Appearance',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildSettingsTile(
                'Dark Mode',
                'Switch between light and dark themes',
                Icons.dark_mode,
                Switch(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Accessibility Section
              Text(
                'Accessibility',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildSettingsTile(
                'Text Size',
                'Adjust text size for better readability',
                Icons.text_fields,
                DropdownButton<String>(
                  value: _getTextSizeKey(themeProvider.textSizeMultiplier),
                  onChanged: (value) {
                    if (value != null) {
                      themeProvider.setTextSize(value);
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'small', child: Text('Small')),
                    DropdownMenuItem(value: 'normal', child: Text('Normal')),
                    DropdownMenuItem(value: 'large', child: Text('Large')),
                    DropdownMenuItem(value: 'xlarge', child: Text('Extra Large')),
                  ],
                ),
              ),
              
              _buildSettingsTile(
                'Accessibility Mode',
                'Enhanced contrast and readability',
                Icons.accessibility,
                Switch(
                  value: themeProvider.accessibilityMode,
                  onChanged: themeProvider.setAccessibilityMode,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // About Section
              Text(
                'About',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildSettingsTile(
                'App Version',
                AppConstants.appVersion,
                Icons.info,
                null,
              ),
              
              _buildSettingsTile(
                'Privacy Policy',
                'View our privacy policy',
                Icons.privacy_tip,
                const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Privacy Policy - Coming Soon!')),
                  );
                },
              ),
              
              _buildSettingsTile(
                'Terms of Service',
                'View terms and conditions',
                Icons.description,
                const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Terms of Service - Coming Soon!')),
                  );
                },
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(String title, String subtitle, IconData icon, Widget? trailing, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2E7D32)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getImpactLevel(double weeklySavings) {
    if (weeklySavings >= 100) return 'Excellent';
    if (weeklySavings >= 50) return 'Great';
    if (weeklySavings >= 25) return 'Good';
    if (weeklySavings >= 10) return 'Fair';
    return 'Getting Started';
  }

  String _getTextSizeKey(double multiplier) {
    if (multiplier <= 0.85) return 'small';
    if (multiplier <= 1.0) return 'normal';
    if (multiplier <= 1.2) return 'large';
    return 'xlarge';
  }

  Future<void> _saveName() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final newName = _nameController.text.trim();
    
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await authService.updateProfile(displayName: newName);
    
    if (success && mounted) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareProgress(double weeklySavings, int completedChallenges, int totalEntries) {
    final text = '''
🌱 My GreenSteps Progress 🌱

This week I saved ${weeklySavings.toStringAsFixed(1)} kg CO₂!
✅ Completed $completedChallenges sustainability challenges
📊 Logged $totalEntries carbon footprint entries

Join me in building a sustainable future! 🌍

#GreenSteps #Sustainability #ClimateAction
    ''';
    
    Share.share(text);
  }

  void _exportData(List<dynamic> carbonEntries) {
    // In a real app, this would generate a CSV or JSON file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export feature - Coming Soon!\nYou have ${carbonEntries.length} entries to export'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }
}
