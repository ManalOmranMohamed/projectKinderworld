import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/app.dart'; // تأكد من أن هذا المسار صحيح لاستدعاء localeProvider

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends ConsumerState<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectLanguage(String languageCode) {
    // تحديث حالة اللغة في البروفايدر
    ref.read(localeProvider.notifier).state = Locale(languageCode);
  }

  void _continueToNextScreen() {
    // الانتقال للشاشة التالية
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // مراقبة اللغة الحالية لتحديث الواجهة فوراً
    final currentLocale = ref.watch(localeProvider);

    final languages = [
      {
        'code': 'en',
        'name': l10n.english,
        'flag': 'EN',
      },
      {
        'code': 'ar',
        'name': l10n.arabic,
        'flag': 'AR',
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value * 100),
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.vertical - 48,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    const SizedBox(height: 40),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.language,
                        size: 60,
                        color: colors.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      l10n.chooseLanguageTitle,
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: AppConstants.largeFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      l10n.chooseLanguageSubtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: AppConstants.fontSize,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Language Options
                    ...languages.map((language) => _buildLanguageCard(language)),

                    const SizedBox(height: 40),

                    // Continue Button
                    ElevatedButton(
                      onPressed: () {
                        _continueToNextScreen();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        l10n.continueText,
                        style: const TextStyle(
                          fontSize: AppConstants.fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(Map<String, dynamic> language) {
    // نستخدم ref.watch لمعرفة أي لغة محددة حالياً
    final currentLocale = ref.watch(localeProvider);
    final isSelected = currentLocale.languageCode == language['code'];
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () => _selectLanguage(language['code']),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? colors.primary : colors.outlineVariant,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Flag
                  Text(
                    language['flag'],
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),

                  // Language Name
                  Text(
                    language['name'],
                    style: TextStyle(
                      fontSize: AppConstants.fontSize,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? colors.onPrimary : colors.onSurface,
                    ),
                  ),
                ],
              ),

              // Selection Indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? colors.onPrimary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: colors.primary,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
