import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:oopsieeats/core/app_icons.dart';
import 'package:oopsieeats/core/routes.dart';
import 'package:oopsieeats/data/api_client.dart';
import 'package:oopsieeats/features/onboarding/models/onboarding_tokens.dart';
import 'package:oopsieeats/features/onboarding/widgets/brand_badge.dart';
import 'package:oopsieeats/features/onboarding/widgets/skip_button.dart';
import 'package:oopsieeats/features/onboarding/widgets/slide_food_discovery.dart';
import 'package:oopsieeats/features/onboarding/widgets/slide_healthy_habits.dart';
import 'package:oopsieeats/features/onboarding/widgets/slide_nutrition_awareness.dart';

/// Professional First-Time User Onboarding Carousel for NutriView.
/// Single Source of Truth: Extreme Neo-Brutalism design system.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isCompleting = false;

  final List<Widget> _slides = const [
    SlideFoodDiscovery(key: ValueKey('slide_1_food_discovery')),
    SlideNutritionAwareness(key: ValueKey('slide_2_nutrition_awareness')),
    SlideHealthyHabits(key: ValueKey('slide_3_healthy_habits')),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheOnboardingAssets();
  }

  void _precacheOnboardingAssets() {
    precacheImage(
      const AssetImage('assets/onboarding/photos/onboarding_1_sticker.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/onboarding/photos/onboarding_2_sticker.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/onboarding/photos/onboarding_3_sticker.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/onboarding/food/nasi_goreng.png'),
      context,
    );
    precacheImage(const AssetImage('assets/onboarding/food/sate.png'), context);
    precacheImage(
      const AssetImage('assets/onboarding/food/bakso.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/onboarding/food/pisang_goreng.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/onboarding/food/martabak.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/onboarding/food/klepon.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/onboarding/food/cabai.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/onboarding/food/tomat.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/onboarding/food/mangga.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/onboarding/food/semangka.png'),
      context,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (_isCompleting || !mounted) return;
    setState(() => _isCompleting = true);

    try {
      final apiClient = context.read<ApiClient>();
      await apiClient.saveOnboardingCompleted(true);
    } catch (e) {
      debugPrint('[Onboarding] Error persisting completed status: $e');
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  void _goToPage(int page) {
    if (!mounted || _isCompleting) return;
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        page.clamp(0, _slides.length - 1),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _nextPage() {
    if (!mounted || _isCompleting) return;
    if (_currentPage < _slides.length - 1) {
      _goToPage(_currentPage + 1);
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastSlide = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: OnboardingTokens.cream,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480.0),
          child: Stack(
            children: [
              // 1. Interactive PageView for the 3 slides
              PageView.builder(
                controller: _pageController,
                physics: _isCompleting
                    ? const NeverScrollableScrollPhysics()
                    : const ClampingScrollPhysics(),
                itemCount: _slides.length,
                onPageChanged: (index) {
                  if (mounted) {
                    setState(() => _currentPage = index);
                  }
                },
                itemBuilder: (context, index) {
                  return _slides[index];
                },
              ),

              // 2. Top Header Navigation (Brand Badge & Skip Button)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const BrandBadge(),

                      // Skip button is smoothly hidden on the last slide
                      AnimatedOpacity(
                        opacity: isLastSlide ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        child: IgnorePointer(
                          ignoring: isLastSlide || _isCompleting,
                          child: SkipButton(onPressed: _completeOnboarding),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Dynamic Footer Controls
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 24.0,
                      right: 24.0,
                      bottom: 18.0,
                    ),
                    child: isLastSlide
                        ? _buildLastSlideFooter()
                        : _buildStandardFooter(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Footer for Slide 1 & 2: Dots on left, round Next button on right
  Widget _buildStandardFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Dots indicator
        _buildDotsIndicator(),

        // Circular Next button
        _NextButton(onPressed: _nextPage),
      ],
    );
  }

  /// Footer for Slide 3: Centered dots above full-width "MULAI SEKARANG" CTA button
  Widget _buildLastSlideFooter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Centered dots indicator
        _buildDotsIndicator(),
        const SizedBox(height: 12.0),

        // Full-width Mulai Sekarang CTA button
        _StartCtaButton(
          isCompleting: _isCompleting,
          onPressed: _completeOnboarding,
        ),
      ],
    );
  }

  /// Interactive pagination dots indicator
  Widget _buildDotsIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_slides.length, (index) {
        final isActive = index == _currentPage;
        return GestureDetector(
          onTap: () => _goToPage(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            width: isActive ? 34.0 : 12.0,
            height: 12.0,
            decoration: BoxDecoration(
              color: isActive ? OnboardingTokens.green : OnboardingTokens.white,
              borderRadius: BorderRadius.circular(999.0),
              border: Border.all(
                color: OnboardingTokens.black,
                width: OnboardingTokens.borderWidthThin,
              ),
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
    const double offsetX = 3.5;
    const double offsetY = 3.5;

    return GestureDetector(
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
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(
          _isPressed ? offsetX : 0.0,
          _isPressed ? offsetY : 0.0,
          0.0,
        ),
        width: 58.0,
        height: 58.0,
        decoration: BoxDecoration(
          color: OnboardingTokens.yellow,
          shape: BoxShape.circle,
          border: Border.all(
            color: OnboardingTokens.black,
            width: OnboardingTokens.borderWidth,
          ),
          boxShadow: _isPressed
              ? []
              : const [
                  BoxShadow(
                    color: OnboardingTokens.black,
                    offset: Offset(offsetX, offsetY),
                    blurRadius: 0.0,
                  ),
                ],
        ),
        child: const Center(
          child: Icon(
            AppIcons.arrowForward,
            color: OnboardingTokens.black,
            size: AppIcons.sizeState,
          ),
        ),
      ),
    );
  }
}

/// Full-width "MULAI SEKARANG" CTA button for Slide 3
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
    const double offsetX = 4.0;
    const double offsetY = 4.0;

    return GestureDetector(
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
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(
          _isPressed ? offsetX : 0.0,
          _isPressed ? offsetY : 0.0,
          0.0,
        ),
        width: double.infinity,
        height: 58.0,
        decoration: BoxDecoration(
          color: OnboardingTokens.orange,
          borderRadius: BorderRadius.circular(999.0),
          border: Border.all(
            color: OnboardingTokens.black,
            width: OnboardingTokens.borderWidth,
          ),
          boxShadow: _isPressed
              ? []
              : const [
                  BoxShadow(
                    color: OnboardingTokens.black,
                    offset: Offset(offsetX, offsetY),
                    blurRadius: 0.0,
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
                      OnboardingTokens.black,
                    ),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'MULAI SEKARANG',
                      style: TextStyle(
                        color: OnboardingTokens.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Icon(
                      AppIcons.arrowForward,
                      color: OnboardingTokens.black,
                      size: AppIcons.sizeHeader,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
