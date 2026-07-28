import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../controllers/profile_setup_controller.dart';

/// Step 5 — "Verify Your Essence" Selfie Verification.
class VerificationStep extends StatelessWidget {
  const VerificationStep({super.key, required this.controller});

  final ProfileSetupController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isVerifying.value) {
        return CameraScannerView(controller: controller);
      }
      
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Verify Your Essence',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Our community thrives on authenticity. Complete a quick selfie verification to receive your gold badge.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 36),
            
            // Concentric Graphic Stack
            Center(
              child: SizedBox(
                width: 250,
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Concentric Outer Circle
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.08),
                          width: 1.5,
                        ),
                      ),
                    ),
                    // Concentric Middle Circle
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.12),
                          width: 1,
                        ),
                      ),
                    ),
                    
                    // Center Squircle Container
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.4),
                          width: 2.0,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 72,
                            color: AppColors.gold.withOpacity(0.15),
                          ),
                          const Icon(
                            Icons.photo_camera_front_outlined,
                            size: 44,
                            color: AppColors.gold,
                          ),
                        ],
                      ),
                    ),
                    
                    // Top Right Badge (Seal with checkmark)
                    Positioned(
                      top: 25,
                      right: 25,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.check,
                          color: Colors.black,
                          size: 14,
                        ),
                      ),
                    ),
                    
                    // Bottom Left Badge (Smile icon)
                    Positioned(
                      bottom: 25,
                      left: 25,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.divider,
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.face_retouching_natural_outlined,
                          color: AppColors.textMuted,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),
            
            // Information Banner Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.gold,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Follow the prompt to capture a live photo.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.85),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            
            // Actions
            PrimaryButton(
              label: 'START VERIFICATION',
              onPressed: controller.startVerification,
            ),
            const SizedBox(height: 12),
            
            // "DO THIS LATER" custom outlined button
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: controller.doThisLaterVerification,
                child: Ink(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.gold.withOpacity(0.4), width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      'DO THIS LATER',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Footer: VERIFIED SOULS counter
            Text(
              'VERIFIED SOULS',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _DigitBox(digit: '8'),
                const SizedBox(width: 4),
                const _DigitBox(digit: '4'),
                const SizedBox(width: 4),
                const _DigitBox(digit: '2'),
                const SizedBox(width: 6),
                Text(
                  ',',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(width: 6),
                const _DigitBox(digit: '9'),
                const SizedBox(width: 4),
                const _DigitBox(digit: '1'),
                const SizedBox(width: 4),
                const _DigitBox(digit: '0'),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }
}

/// Simulated Camera Verification Scanner View.
class CameraScannerView extends StatefulWidget {
  final ProfileSetupController controller;
  const CameraScannerView({super.key, required this.controller});

  @override
  State<CameraScannerView> createState() => _CameraScannerViewState();
}

class _CameraScannerViewState extends State<CameraScannerView>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  int _currentStatusIndex = 0;
  final List<String> _statusTexts = [
    'Align your face in the oval guide...',
    'Scanning facial structure...',
    'Analyzing biometrics...',
    'Verification successful!',
  ];

  late final List<Duration> _statusDurations = const [
    Duration(milliseconds: 1200),
    Duration(milliseconds: 1600),
    Duration(milliseconds: 1200),
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    _startStatusProgression();
  }

  void _startStatusProgression() async {
    for (int i = 0; i < _statusDurations.length; i++) {
      if (!mounted) return;
      await Future.delayed(_statusDurations[i]);
      if (!mounted) return;
      setState(() {
        _currentStatusIndex = i + 1;
      });
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.95),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Liveness Scan',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Keep your device steady. Exclusivity starts with validation.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          
          // Camera scanner viewport
          SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glowing outer rotating circular progress indicators
                Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 4),
                    builder: (context, value, child) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 3,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(AppColors.gold),
                        backgroundColor: AppColors.divider.withOpacity(0.2),
                      );
                    },
                  ),
                ),
                
                // Camera screen simulator
                Container(
                  width: 242,
                  height: 242,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background.withOpacity(0.8),
                    border: Border.all(
                      color: AppColors.gold.withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.08),
                        blurRadius: 30,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Simulated face mask silhouette
                      Icon(
                        Icons.face_unlock_outlined,
                        size: 140,
                        color: AppColors.gold.withOpacity(0.18),
                      ),
                      
                      // Animated scanning line
                      AnimatedBuilder(
                        animation: _scanAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: _scanAnimation.value * 190 + 26,
                            left: 30,
                            right: 30,
                            child: child!,
                          );
                        },
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withOpacity(0.95),
                                blurRadius: 10,
                                spreadRadius: 3,
                              ),
                            ],
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.gold,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Success Overlay Circle and checkmark
                      if (_currentStatusIndex == 3)
                        Container(
                          color: Colors.black.withOpacity(0.65),
                          alignment: Alignment.center,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 550),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: child,
                              );
                            },
                            child: Container(
                              width: 84,
                              height: 84,
                              decoration: const BoxDecoration(
                                color: AppColors.gold,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.black,
                                size: 50,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          
          // Status indicator and text
          SizedBox(
            height: 32,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.25),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _statusTexts[_currentStatusIndex],
                  key: ValueKey<int>(_currentStatusIndex),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _currentStatusIndex == 3
                        ? AppColors.gold
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DigitBox extends StatelessWidget {
  final String digit;
  const _DigitBox({required this.digit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        digit,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.gold,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}
