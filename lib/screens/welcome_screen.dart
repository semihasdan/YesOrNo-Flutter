import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/routes/app_routes.dart';
import '../core/di/service_locator.dart';
import '../core/utils/result.dart';
import '../widgets/yes_no_logo.dart';
import '../widgets/spinning_logo_loader.dart';

/// Welcome/Login screen - First screen when app is opened
/// Shows Quick Start button and social login options (Apple, Google)
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Pulse animation for Quick Start button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onQuickStart() async {
    // Prevent multiple taps
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get UserService from service locator
      final userService = serviceLocator.userService;
      
      // Execute setup flow
      final result = await userService.handleQuickStartSetup();

      if (!mounted) return;

      if (result is Success) {
        final userProfile = (result as Success).data;
        debugPrint('Setup successful for user: ${userProfile.username}');
        
        // Navigate to Home Screen
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        
      } else if (result is Failure) {
        // Show error message
        _showErrorDialog((result as Failure).message);
      }
      
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('An unexpected error occurred: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onGoogleLogin() {
    // TODO: Implement Google Sign-In
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign-In coming soon!'),
        backgroundColor: AppColors.primaryCyan,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onAppleLogin() {
    // TODO: Implement Apple Sign-In
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apple Sign-In coming soon!'),
        backgroundColor: AppColors.primaryCyan,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Show error dialog to user
  void _showErrorDialog(String message) {
    // Check if it's a Firestore permission error
    final bool isPermissionError = message.contains('permission-denied');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark2,
        title: Text(
          isPermissionError ? 'Firebase Setup Required' : 'Setup Failed',
          style: AppTextStyles.heading3.copyWith(color: AppColors.primaryCyan),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPermissionError 
                    ? 'Firestore security rules need to be configured.'
                    : message,
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              ),
              if (isPermissionError)
                const SizedBox(height: 16),
              if (isPermissionError)
                Text(
                  'Steps to fix:',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primaryCyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (isPermissionError)
                const SizedBox(height: 8),
              if (isPermissionError)
                Text(
                  '1. Go to Firebase Console\n'
                  '2. Click Firestore Database\n'
                  '3. Click Rules tab\n'
                  '4. See FIREBASE_SETUP_GUIDE.md\n'
                  '   for the correct rules\n'
                  '5. Click Publish',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTextStyles.buttonLarge.copyWith(color: AppColors.primaryCyan),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundDark,
              Color(0xFF100814),
              Color(0xFF0A040C),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // Logo with Y/N design
                      YesNoLogo(size: 200,),

                      const SizedBox(height: 64),

                      // Quick Start Button
                      _buildQuickStartButton(),

                      const SizedBox(height: 64),

                      // Social Login Buttons
                      _buildSocialLoginButtons(),

                      const Spacer(),
                    ],
                  ),
                ),
              ),
              
              // Loading overlay
              if (_isLoading)
                Container(
                  color: Colors.black87,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SpinningLogoLoader(size: 120),
                        SizedBox(height: 32),
                        Text(
                          'Authenticating...',
                          style: TextStyle(
                            color: AppColors.primaryCyan,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // New, bigger logo without the line - a glowing circle
        Container(
          width: 120, // Increased size for the logo
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryCyan, // The cyan color from the image
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryCyan.withOpacity(0.7),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32), // Added space between logo and title

        // App Title
        Text(
          'Yes Or No',
          style: AppTextStyles.heading1.copyWith(
            fontSize: 32,
            letterSpacing: 4,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'The Ultimate Word Deduction Game',
          style: AppTextStyles.subtitle.copyWith(
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStartButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF00E5FF), // Cyan
              Color(0xFFFF00FF), // Magenta
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryCyan.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: AppColors.secondaryMagenta.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _onQuickStart,
            borderRadius: BorderRadius.circular(32),
            child: Center(
              child: Text(
                'Quick Start',
                style: AppTextStyles.buttonLarge.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        Text(
          'Or sign in with',
          style: AppTextStyles.subtitle.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Sign-In Button
            _buildSocialButton(
              onTap: _onGoogleLogin,
              icon: _buildGoogleIcon(),
              tooltip: 'Sign in with Google',
            ),

            const SizedBox(width: 24),

            // Apple Sign-In Button
            _buildSocialButton(
              onTap: _onAppleLogin,
              icon: const Icon(
                Icons.apple,
                color: Colors.white,
                size: 32,
              ),
              tooltip: 'Sign in with Apple',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onTap,
    required Widget icon,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(32),
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: GoogleLogoPainter(),
      ),
    );
  }
}

/// Custom painter for Google logo
class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Google "G" logo colors
    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    final redPaint = Paint()..color = const Color(0xFFEA4335);
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final greenPaint = Paint()..color = const Color(0xFF34A853);

    // Draw simplified Google logo
    // Blue section
    final bluePath = Path()
      ..moveTo(width * 0.8, height * 0.5)
      ..arcTo(
        Rect.fromLTWH(0, 0, width, height),
        -1.57,
        1.57,
        false,
      );
    canvas.drawPath(bluePath, bluePaint);

    // Red section
    final redPath = Path()
      ..moveTo(width * 0.5, 0)
      ..arcTo(
        Rect.fromLTWH(0, 0, width, height),
        -1.57,
        -1.57,
        false,
      );
    canvas.drawPath(redPath, redPaint);

    // Yellow section
    final yellowPath = Path()
      ..moveTo(0, height * 0.5)
      ..arcTo(
        Rect.fromLTWH(0, 0, width, height),
        3.14,
        -1.57,
        false,
      );
    canvas.drawPath(yellowPath, yellowPaint);

    // Green section
    final greenPath = Path()
      ..moveTo(width * 0.5, height)
      ..arcTo(
        Rect.fromLTWH(0, 0, width, height),
        1.57,
        -1.57,
        false,
      );
    canvas.drawPath(greenPath, greenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}