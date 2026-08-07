import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_pages.dart';

/// Sign-in gateway screen shown right after the onboarding carousel.
/// Users choose a social provider (Facebook, Apple, Google) or phone.
class SignInView extends StatelessWidget {
  const SignInView({super.key});

  // ── Navigation helpers ──────────────────────────────────────────────────────

  void _onFacebook() => Get.toNamed(Routes.login);
  void _onApple() => Get.toNamed(Routes.login);
  void _onGoogle() => Get.toNamed(Routes.login);

  void _onPhone() async {
    // Opens the native phone dialpad with an empty call intent.
    final uri = Uri(scheme: 'tel', path: '');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback: navigate to login if dialpad is unavailable (e.g. simulator).
      Get.toNamed(Routes.login);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // "sign in" label at the very top-left (matches the design)
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'sign in',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            const Spacer(flex: 2),

            // ── Logo block ──────────────────────────────────────────────────
            _LogoBlock(),

            const Spacer(flex: 2),

            // ── Live users counter ──────────────────────────────────────────
            const _LiveUsersCounter(),

            const Spacer(flex: 3),

            // ── "SIGN IN WITH" label ────────────────────────────────────────
            Text(
              'SIGN IN WITH',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 22),

            // ── Social buttons row ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialButton(
                  id: 'btn_signin_facebook',
                  icon: Icons.facebook,
                  onTap: _onFacebook,
                ),
                const SizedBox(width: 16),
                _SocialButton(
                  id: 'btn_signin_apple',
                  icon: Icons.apple,
                  onTap: _onApple,
                ),
                const SizedBox(width: 16),
                _SocialButton(
                  id: 'btn_signin_google',
                  customLabel: 'G',
                  onTap: _onGoogle,
                ),
                const SizedBox(width: 16),
                _SocialButton(
                  id: 'btn_signin_phone',
                  icon: Icons.phone,
                  onTap: _onPhone,
                ),
              ],
            ),

            const Spacer(flex: 4),

            // ── Terms footer ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
              child: Text.rich(
                TextSpan(
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                  children: [
                    const TextSpan(text: 'By signing in you are agreeing to our '),
                    TextSpan(
                      text: 'Terms and Conditions',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gold,
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.gold,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Logo block ────────────────────────────────────────────────────────────────

class _LogoBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/bummps-icon.png',
          height: 250,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.favorite,
            color: AppColors.gold,
            size: 90,
          ),
        ),
        const SizedBox(height: 1),

        Image.asset(
          'assets/images/bummps..png',
          height: 36,
          errorBuilder: (_, __, ___) => Text(
            'bummps.',
            style: AppTextStyles.displayLarge.copyWith(
              color: AppColors.gold,
              fontSize: 32,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),

        Image.asset(
          'assets/images/realPeopleRealMatches.png',
          height: 18,
          errorBuilder: (_, __, ___) => Text(
            'Real People Real Matches',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Live users counter ────────────────────────────────────────────────────────

class _LiveUsersCounter extends StatelessWidget {
  const _LiveUsersCounter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline, color: AppColors.gold, size: 20),
          const SizedBox(width: 8),
          ..._digitBoxes('6344'),
          const SizedBox(width: 10),
          // Vertical separator
          Container(width: 1, height: 22, color: AppColors.gold.withOpacity(0.4)),
          const SizedBox(width: 10),
          Text(
            'LIVE\nUSERS',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gold,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Renders each digit in its own amber-bordered box.
  static List<Widget> _digitBoxes(String number) {
    return number.split('').map((d) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gold, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          d,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.gold,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      );
    }).toList();
  }
}

// ── Social icon button ────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.id,
    required this.onTap,
    this.icon,
    this.customLabel,
  }) : assert(icon != null || customLabel != null);

  final String id;
  final VoidCallback onTap;
  final IconData? icon;
  final String? customLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.gold, width: 1.5),
          color: Colors.transparent,
        ),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, color: AppColors.gold, size: 22)
            : Text(
                customLabel!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
      ),
    );
  }
}
