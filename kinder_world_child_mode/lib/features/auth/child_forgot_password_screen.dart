import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:kinder_world/core/theme/app_colors.dart';

class ChildForgotPasswordScreen extends StatefulWidget {
  const ChildForgotPasswordScreen({super.key});

  @override
  State<ChildForgotPasswordScreen> createState() =>
      _ChildForgotPasswordScreenState();
}

class _ChildForgotPasswordScreenState
    extends State<ChildForgotPasswordScreen> {
  final _parentEmailController = TextEditingController();
  final _childIdController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _parentEmailController.dispose();
    _childIdController.dispose();
    super.dispose();
  }

  void _sendHelp() {
    if (_sending) return;
    setState(() => _sending = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('A helper message was sent to your parent.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF7E8),
              Color(0xFFEFF8FF),
              Color(0xFFF3E7FF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(Icons.arrow_back, color: colors.onSurface),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE6F1),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: colors.shadow.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.help_rounded,
                      size: 60,
                      color: Color(0xFFFF6FA6),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Need Help?',
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: AppConstants.largeFontSize * 1.1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Tell us your ID and your parent’s email.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Child ID',
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: AppConstants.fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _childIdController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Ava123',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Parent Email',
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: AppConstants.fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _parentEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'parent@email.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _sendHelp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8AB3),
                      foregroundColor: colors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _sending
                        ? CircularProgressIndicator(
                            color: colors.onPrimary,
                          )
                        : const Text(
                            'Ask Parent for Help',
                            style: TextStyle(
                              fontSize: AppConstants.fontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Or try again with your pictures.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/child/login'),
                    child: const Text('Back to Child Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
