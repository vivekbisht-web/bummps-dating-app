import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_pages.dart';

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
                  icon: FontAwesomeIcons.facebookF,
                  backgroundColor: AppColors.gold,
                  iconColor: AppColors.background,
                  hasBorder: true,
                  iconSize: 38,
                  onTap: _onFacebook,
                ),
                const SizedBox(width: 16),
                _SocialButton(
                  id: 'btn_signin_apple',
                  icon: FontAwesomeIcons.apple,
                  backgroundColor: AppColors.gold,
                  iconColor: AppColors.background,
                  hasBorder: false,
                  iconSize: 38,
                  onTap: _onApple,
                ),
                const SizedBox(width: 16),
                _SocialButton(
                  id: 'btn_signin_google',
                  icon: FontAwesomeIcons.google,//social media icons update
                  backgroundColor: Colors.transparent,
                  iconColor: AppColors.gold,
                  hasBorder: false,
                  iconSize: 50,
                  onTap: _onGoogle,
                ),
                const SizedBox(width: 16),
                _SocialButton(
                  id: 'btn_signin_phone',
                  icon: Icons.phone, //social media icons update
                  backgroundColor: AppColors.gold,
                  iconColor: AppColors.background,
                  hasBorder: false,
                  iconSize: 38,
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
          'assets/images/bummps-singin-view-icon.png',
          height: 270,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.favorite,
            color: AppColors.gold,
            size: 120,
          ),
        ),
        const SizedBox(height: 6),

        Image.asset(
          'assets/images/bummps..png',
          height: 44,
          errorBuilder: (_, __, ___) => Text(
            'bummps.',
            style: AppTextStyles.displayLarge.copyWith(
              color: AppColors.gold,
              fontSize: 32,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 6),

        Image.asset(
          'assets/images/realPeopleRealMatches.png',
          height: 30,
          errorBuilder: (_, __, ___) => Text(
            'Real People Real Matches',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              fontSize: 22,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Live users counter ────────────────────────────────────────────────────────

class _LiveUsersCounter extends StatefulWidget {
  const _LiveUsersCounter({super.key});

  @override
  State<_LiveUsersCounter> createState() => _LiveUsersCounterState();
}

class _LiveUsersCounterState extends State<_LiveUsersCounter>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  Timer? _timer;
  AnimationController? _animationController;
  Animation<int>? _animation;
  int _targetCount = 23; // default fallback target

  @override
  void initState() {
    super.initState();
    // Start initial animation to our default target (23) immediately
    _animateToCount(0, _targetCount);
    // Fetch live user count from API immediately
    _fetchLiveCount();
    // Start polling every 15 seconds for real updates
    _startPollingTimer();
  }

  void _animateToCount(int begin, int end) {
    _animationController?.dispose();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = IntTween(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOutCubic,
      ),
    );
    _animation!.addListener(() {
      if (mounted) {
        setState(() {
          _count = _animation!.value;
        });
      }
    });
    _animationController!.forward();
  }

  Future<void> _fetchLiveCount() async {
    try {
      final dio = Dio();
      final response = await dio.get('https://datingapp-oz22.onrender.com/api/auth/count');
      if (response.statusCode == 200 && response.data != null) {
        final totalUsers = response.data['totalUsers'];
        int? parsedCount;
        if (totalUsers is int) {
          parsedCount = totalUsers;
        } else if (totalUsers is String) {
          parsedCount = int.tryParse(totalUsers);
        }
        if (parsedCount != null && parsedCount > 0 && parsedCount != _targetCount) {
          _targetCount = parsedCount;
          if (mounted) {
            // Animate from whatever the current count is, up/down to the newly fetched count
            _animateToCount(_count, _targetCount);
          }
        }
      }
    } catch (e) {
      // Fail silently and keep the default animation
    }
  }

  void _startPollingTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _fetchLiveCount();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pad left with 0s to keep it 4 digits from the start, avoiding layout jumps
    final paddedCount = _count.toString().padLeft(4, '0');

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
          ..._digitBoxes(paddedCount),
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

  /// Renders each digit in its own amber-bordered box with a smooth vertical slide/fade animation.
  List<Widget> _digitBoxes(String number) {
    final digits = number.split('');
    final List<Widget> boxes = [];
    for (int i = 0; i < digits.length; i++) {
      final d = digits[i];
      boxes.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gold, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.4),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              d,
              key: ValueKey<String>('digit_${i}_$d'),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }
    return boxes;
  }
}

// ── Social icon button ────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.id,
    required this.onTap,
    required this.icon,
    this.backgroundColor = Colors.transparent,
    this.iconColor = AppColors.gold,
    this.hasBorder = true,
    this.iconSize = 22,
  });

  final String id;
  final VoidCallback onTap;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final bool hasBorder;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: hasBorder ? Border.all(color: AppColors.gold, width: 1.5) : null,
          color: backgroundColor,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }
}
