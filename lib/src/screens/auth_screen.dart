import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../core/responsive_layout.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  final _registerNameController = TextEditingController();
  
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  
  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    

  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    _registerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF4CAF50),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: ResponsiveLayout.getPadding(context),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveLayout.isMobileLayout(context) ? double.infinity : 500,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min, // Overflow fix
                    children: [
                      // Logo and Title
Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Image.asset(
    'assets/images/GreenSteps_Transparent.png', // or use SvgPicture.asset(...)
    width: 160,
    fit: BoxFit.contain,
    semanticLabel: 'GreenSteps',
  ),
),


                      Text(
                        'Your Sustainable Living Guide',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      
                      // Tab Controller
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey[600],
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          tabAlignment: TabAlignment.fill,
                          tabs: const [
                            Tab(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text('Login'),
                              ),
                            ),
                            Tab(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text('Register'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Tab Content 
SizedBox(
  height: 400, // or MediaQuery.of(context).size.height * 0.6
  child: TabBarView(
    controller: _tabController,
    children: [
      SingleChildScrollView(child: _buildLoginTab()),
      SingleChildScrollView(child: _buildRegisterTab()),
    ],
  ),
),


                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTab() {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Form(
          key: _loginFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // ADD THIS LINE
            children: [
              TextFormField(
                controller: _loginEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _loginPasswordController,
                obscureText: _obscureLoginPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureLoginPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureLoginPassword = !_obscureLoginPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              if (authService.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    authService.error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: authService.isLoading ? null : _handleLogin,
                  child: authService.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: authService.isLoading ? null : _handleGoogleLogin,
                  icon: const Icon(Icons.login, color: Color(0xFF2E7D32)),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2E7D32)),
                    foregroundColor: const Color(0xFF2E7D32),
                  ),
                ),
              ),
              // const SizedBox(height: 16),
              
              // Container(
              //   padding: const EdgeInsets.all(16),
              //   decoration: BoxDecoration(
              //     color: Colors.blue.shade50,
              //     borderRadius: BorderRadius.circular(8),
              //     border: Border.all(color: Colors.blue.shade200),
              //   ),
              //   child: Column(
              //     children: [
              //       Text(
              //         'Demo Credentials',
              //         style: TextStyle(
              //           fontWeight: FontWeight.bold,
              //           color: Colors.blue.shade700,
              //         ),
              //       ),
              //       const SizedBox(height: 4),
              //       Text(
              //         'Email: account4youGreensteps@gmail.com\nPassword: 123456',
              //         style: TextStyle(
              //           fontSize: 12,
              //           color: Colors.blue.shade600,
              //         ),
              //         textAlign: TextAlign.center,
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegisterTab() {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return SingleChildScrollView( // ADD THIS WRAPPER
          child: Form(
            key: _registerFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // ADD THIS
              children: [
                TextFormField(
                  controller: _registerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _registerEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _registerPasswordController,
                  obscureText: _obscureRegisterPassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureRegisterPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscureRegisterPassword = !_obscureRegisterPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _registerConfirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _registerPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                if (authService.error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      authService.error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: authService.isLoading ? null : _handleRegister,
                    child: authService.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Create Account'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final success = await authService.signInWithEmailAndPassword(
        _loginEmailController.text.trim(),
        _loginPasswordController.text,
      );
      
      if (success && mounted) {
        context.replace('/home');
      }
    }
  }

  Future<void> _handleRegister() async {
    if (_registerFormKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final success = await authService.createUserWithEmailAndPassword(
        _registerEmailController.text.trim(),
        _registerPasswordController.text,
        _registerNameController.text.trim(),
      );
      
      if (success && mounted) {
        // Show success message and switch to login tab
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please login.'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        _tabController.animateTo(0);
        
        // Clear register form
        _registerEmailController.clear();
        _registerPasswordController.clear();
        _registerConfirmPasswordController.clear();
        _registerNameController.clear();
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    final success = await authService.signInWithGoogle();
    
    if (success && mounted) {
      context.replace('/home');
    }
  }
}
