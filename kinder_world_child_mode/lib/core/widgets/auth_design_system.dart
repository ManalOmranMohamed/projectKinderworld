import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AUTH COLOR TOKENS
// Fixed palette used across the entire pre-auth / auth flow.
// Independent of the user's chosen theme so the first-impression is consistent.
// ─────────────────────────────────────────────────────────────────────────────

class AuthColors {
  AuthColors._();

  // Brand (blue)
  static const Color brand      = Color(0xFF1976D2);
  static const Color brandDeep  = Color(0xFF0D47A1);
  static const Color brandLight = Color(0xFF42A5F5);

  // Parent identity (green)
  static const Color parent      = Color(0xFF2E7D32);
  static const Color parentLight = Color(0xFF66BB6A);
  static const Color parentBg    = Color(0xFFE8F5E9);

  // Child identity (warm orange)
  static const Color child      = Color(0xFFE64A19);
  static const Color childLight = Color(0xFFFF7043);
  static const Color childBg    = Color(0xFFFBE9E7);

  // Inputs
  static const Color inputBg     = Color(0xFFF8F9FB);
  static const Color inputBorder = Color(0xFFE2E8F0);

  // Feedback
  static const Color error   = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);

  // Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textMuted   = Color(0xFF6B7280);
  static const Color textHint    = Color(0xFFA0AEC0);

  // Structural
  static const Color divider     = Color(0xFFE8ECF4);
  static const Color pageBg      = Color(0xFFF7F9FC);
}

// ─────────────────────────────────────────────────────────────────────────────
// BRAND MARK  (gradient square with rounded corners)
// ─────────────────────────────────────────────────────────────────────────────

class AuthBrandMark extends StatelessWidget {
  final double size;

  const AuthBrandMark({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1976D2), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withValues(alpha: 0.40),
            blurRadius: size * 0.55,
            offset: Offset(0, size * 0.15),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'K',
          style: TextStyle(
            fontSize: size * 0.52,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -2,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AUTH TEXT FIELD  (label above, fully styled)
// ─────────────────────────────────────────────────────────────────────────────

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final Color accentColor;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = false,
    this.accentColor = AuthColors.brand,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF374151),
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          autocorrect: autocorrect,
          enableSuggestions: false,
          enabled: enabled,
          validator: validator,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AuthColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AuthColors.textHint,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(prefixIcon, size: 20, color: AuthColors.textHint),
            suffixIcon: suffix,
            filled: true,
            fillColor: AuthColors.inputBg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AuthColors.inputBorder, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AuthColors.inputBorder, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AuthColors.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AuthColors.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AUTH PRIMARY BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color color;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.color = AuthColors.brand,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withValues(alpha: 0.5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AUTH SECONDARY BUTTON (outlined)
// ─────────────────────────────────────────────────────────────────────────────

class AuthSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const AuthSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AuthColors.brand,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 1.5),
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OR DIVIDER
// ─────────────────────────────────────────────────────────────────────────────

class AuthOrDivider extends StatelessWidget {
  final String label;

  const AuthOrDivider({super.key, this.label = 'OR'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AuthColors.divider, thickness: 1.5),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AuthColors.textHint,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AuthColors.divider, thickness: 1.5),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN HEADER  (title + subtitle block)
// ─────────────────────────────────────────────────────────────────────────────

class AuthScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AuthColors.textPrimary,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AuthColors.textMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// IDENTITY HEADER STRIP  (green for parent, orange for child)
// ─────────────────────────────────────────────────────────────────────────────

class AuthIdentityHeader extends StatelessWidget {
  final List<Color> gradientColors;
  final IconData icon;
  final String label;
  final VoidCallback onBack;

  const AuthIdentityHeader({
    super.key,
    required this.gradientColors,
    required this.icon,
    required this.label,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 16, 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: onBack,
              ),
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PASSWORD STRENGTH INDICATOR
// ─────────────────────────────────────────────────────────────────────────────

class PasswordStrengthBar extends StatelessWidget {
  final String password;

  const PasswordStrengthBar({super.key, required this.password});

  int get _strength {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{};:,.<>?]'))) score++;
    return score;
  }

  Color get _color {
    switch (_strength) {
      case 1:
        return const Color(0xFFD32F2F);
      case 2:
        return const Color(0xFFFB8C00);
      case 3:
        return const Color(0xFFFDD835);
      case 4:
        return const Color(0xFF2E7D32);
      default:
        return AuthColors.divider;
    }
  }

  String get _label {
    switch (_strength) {
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 3 ? 4 : 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < _strength ? _color : AuthColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          }),
        ),
        if (_label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            _label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ],
    );
  }
}
