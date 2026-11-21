import 'package:flutter/material.dart';
import 'package:oopsieeats/core/app_icons.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/core/routes.dart';
import 'package:oopsieeats/data/api_client.dart';
import 'package:oopsieeats/features/onboarding/models/onboarding_tokens.dart';
import 'package:oopsieeats/features/onboarding/widgets/brand_badge.dart';
import 'package:oopsieeats/features/onboarding/widgets/skip_button.dart';
import 'package:oopsieeats/features/onboarding/widgets/slide_food_discovery.dart';
import 'package:oopsieeats/features/onboarding/widgets/slide_healthy_habits.dart';
import 'package:oopsieeats/features/onboarding/widgets/slide_nutrition_awareness.dart';
import 'package:provider/provider.dart';

/// Main NutriView Onboarding Screen featuring a 3-slide Neo-Brutalist
/// editorial poster carousel, top brand badge + skip button, and bottom
/// pagination indicator + CTA controls using the official [NeoTokens] palette.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _totalSlides = 3;

  late final PageController _pageController;
  int _currentIndex = 0;
  bool _isCompleting = false;
  bool _didPrecache = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didPrecache) {
      _didPrecache = true;
      _precacheOnboardingAssets();
    }
  }

  void _precacheOnboardingAssets() {
    const assets = [
      'assets/onboarding/photos/onboarding_1_sticker.png',
      'assets/onboarding/photos/onboarding_2_sticker.png',
      'assets/onboarding/photos/onboarding_3_sticker.png',
      'assets/onboarding/food/nasi_goreng.png',
      'assets/onboarding/food/sate.png',
      'assets/onboarding/food/bakso.png',
      'assets/onboarding/food/pisang_goreng.png',
      'assets/onboarding/food/martabak.png',
      'assets/onboarding/food/klepon.png',
      'assets/onboarding/food/cabai.png',
      'assets/onboarding/food/tomat.png',
      'assets/onboarding/food/mangga.png',
      'assets/onboarding/food/semangka.png',
      'assets/onboarding/food/ayam_goreng.png',
      'assets/onboarding/food/rendang.png',
      'assets/onboarding/food/wortel.png',
    ];
    for (final assetPath in assets) {
      precacheImage(AssetImage(assetPath), context).catchError((_) {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);

    try {
      final apiClient = context.read<ApiClient>();
      await apiClient.saveOnboardingCompleted(true);
    } catch (_) {
      // Fail-open so user is never trapped on onboarding screen
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  void _handleNextSlide() {
    if (_currentIndex < _totalSlides - 1) {
      if (NeoMotion.isAnimationDisabled(context)) {
        _pageController.jumpToPage(_currentIndex + 1);
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 360),
          curve: NeoMotion.curveDecelerate,
        );
      }
    } else {
      _completeOnboarding();
    }
  }

  void _jumpToSlide(int index) {
    if (index == _currentIndex) return;
    if (NeoMotion.isAnimationDisabled(context)) {
      _pageController.jumpToPage(index);
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 320),
        curve: NeoMotion.curveDecelerate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastSlide = _currentIndex == _totalSlides - 1;

    return Scaffold(
      backgroundColor: NeoTokens.warmBackground,
      body: Stack(
        children: [
          // 1. Full-Screen 3-Slide Carousel
          Positioned.fill(
            child: PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                if (mounted) {
                  setState(() => _currentIndex = index);
                }
              },
              children: const [
                SlideFoodDiscovery(),
                SlideNutritionAwareness(),
                SlideHealthyHabits(),
              ],
            ),
          ),

          // 2. Top Bar Overlay (BrandBadge + SkipButton)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const BrandBadge(),
                    if (!isLastSlide) SkipButton(onPressed: _completeOnboarding),
                  ],
                ),
              ),
            ),
          ),

          // 3. Bottom Navigation & CTA Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 20.0),
                child: AnimatedSwitcher(
                  duration: NeoMotion.getDuration(
                    context,
                    NeoMotion.durationShort,
                  ),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  child: isLastSlide
                      ? Column(
                          key: const ValueKey('last_slide_controls'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildPageIndicator(centered: true),
                            const SizedBox(height: 14.0),
                            _StartCtaButton(
                              isCompleting: _isCompleting,
                              onPressed: _completeOnboarding,
                            ),
                          ],
                        )
                      : Row(
                          key: const ValueKey('standard_slide_controls'),
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildPageIndicator(centered: false),
                            _NextButton(onPressed: _handleNextSlide),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator({required bool centered}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: centered
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: List.generate(_totalSlides, (index) {
        final bool isActive = index == _currentIndex;
        return GestureDetector(
          onTap: () => _jumpToSlide(index),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: NeoMotion.getDuration(context, NeoMotion.durationShort),
            curve: NeoMotion.curveDecelerate,
            margin: const EdgeInsets.only(right: 8.0),
            width: isActive ? 38.0 : 12.0,
            height: 12.0,
            decoration: BoxDecoration(
              color: isActive ? NeoTokens.primaryGreen : NeoTokens.white,
              borderRadius: BorderRadius.circular(NeoTokens.radiusPill),
              border: Border.all(
                color: NeoTokens.black,
                width: OnboardingTokens.borderWidthThin,
              ),
              boxShadow: isActive
                  ? const [
                      BoxShadow(
                        color: NeoTokens.black,
                        offset: NeoTokens.shadowOffsetSmall,
                        blurRadius: NeoTokens.shadowBlurRadius,
                      ),
                    ]
                  : const [],
            ),
          ),
        );
      }),
    );
  }
}

/// Circular Next CTA button for Slide 1 and 2
class _NextButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _NextButton({required this.onPressed});

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double offsetX = 4.0;
    const double offsetY = 4.0;

    return Semantics(
      button: true,
      label: 'Slide berikutnya',
      child: GestureDetector(
        onTapDown: (_) {
          if (mounted) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (mounted) setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () {
          if (mounted) setState(() => _isPressed = false);
        },
        child: AnimatedContainer(
          duration: NeoMotion.getDuration(context, NeoMotion.durationFast),
          transform: Matrix4.translationValues(
            _isPressed ? offsetX : 0.0,
            _isPressed ? offsetY : 0.0,
            0.0,
          ),
          width: 58.0,
          height: 58.0,
          decoration: BoxDecoration(
            color: NeoTokens.vividYellow,
            shape: BoxShape.circle,
            border: Border.all(
              color: NeoTokens.black,
              width: OnboardingTokens.borderWidthThick,
            ),
            boxShadow: _isPressed
                ? []
                : const [
                    BoxShadow(
                      color: NeoTokens.black,
                      offset: Offset(offsetX, offsetY),
                      blurRadius: NeoTokens.shadowBlurRadius,
                    ),
                  ],
          ),
          child: const Center(
            child: Icon(
              AppIcons.arrowForward,
              color: NeoTokens.black,
              size: AppIcons.sizeState,
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width Primary Green & Vivid Yellow "MULAI SEKARANG" CTA button for Slide 3
class _StartCtaButton extends StatefulWidget {
  final bool isCompleting;
  final VoidCallback onPressed;

  const _StartCtaButton({required this.isCompleting, required this.onPressed});

  @override
  State<_StartCtaButton> createState() => _StartCtaButtonState();
}

class _StartCtaButtonState extends State<_StartCtaButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double offsetX = 4.5;
    const double offsetY = 4.5;

    return Semantics(
      button: true,
      label: 'Mulai Sekarang',
      child: GestureDetector(
        onTapDown: widget.isCompleting
            ? null
            : (_) {
                if (mounted) setState(() => _isPressed = true);
              },
        onTapUp: widget.isCompleting
            ? null
            : (_) {
                if (mounted) setState(() => _isPressed = false);
                widget.onPressed();
              },
        onTapCancel: () {
          if (mounted) setState(() => _isPressed = false);
        },
        child: AnimatedContainer(
          duration: NeoMotion.getDuration(context, NeoMotion.durationFast),
          transform: Matrix4.translationValues(
            _isPressed ? offsetX : 0.0,
            _isPressed ? offsetY : 0.0,
            0.0,
          ),
          width: double.infinity,
          height: 58.0,
          decoration: BoxDecoration(
            color: NeoTokens.primaryGreen,
            borderRadius: BorderRadius.circular(NeoTokens.radiusPill),
            border: Border.all(
              color: NeoTokens.black,
              width: OnboardingTokens.borderWidthThick,
            ),
            boxShadow: _isPressed
                ? []
                : const [
                    BoxShadow(
                      color: NeoTokens.black,
                      offset: Offset(offsetX, offsetY),
                      blurRadius: NeoTokens.shadowBlurRadius,
                    ),
                  ],
          ),
          child: Center(
            child: widget.isCompleting
                ? const SizedBox(
                    width: 24.0,
                    height: 24.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.8,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        NeoTokens.white,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'MULAI SEKARANG',
                        style: TextStyle(
                          color: NeoTokens.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Container(
                        width: 28.0,
                        height: 28.0,
                        decoration: BoxDecoration(
                          color: NeoTokens.vividYellow,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: NeoTokens.black,
                            width: 1.8,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            AppIcons.arrowForward,
                            color: NeoTokens.black,
                            size: AppIcons.sizeMedium,
                          ),
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
