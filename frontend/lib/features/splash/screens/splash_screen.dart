import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/core/routes.dart';
import 'package:oopsieeats/data/api_client.dart';
import 'package:oopsieeats/features/auth/providers/auth_provider.dart';
import 'package:oopsieeats/features/profile/providers/profile_provider.dart';
import 'package:oopsieeats/features/splash/widgets/neo_splash_badge.dart';

/// Clean, consumer-focused Neo-Brutalism Splash Screen for NutriView.
/// Displays an iconic nutrition Apple mark, confident editorial wordmark,
/// and warm consumer tagline without developer or technical jargon.
class SplashScreen extends StatefulWidget {
  final Duration? minimumDuration;
  final Duration authTimeout;

  const SplashScreen({
    super.key,
    this.minimumDuration,
    this.authTimeout = const Duration(seconds: 5),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _leafAngle;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  bool _isNavigating = false;
  bool _hasCompletedOnboarding = true;

  @override
  void initState() {
    super.initState();

    final totalDuration =
        widget.minimumDuration ?? const Duration(milliseconds: 650);

    _controller = AnimationController(vsync: this, duration: totalDuration);

    // 1. Logo Entrance: controlled spring scale
    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    // 2. Subtle Secondary Motion: gentle micro-dip on the leaf (fresh & playful)
    _leafAngle =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 0.0,
              end: 0.08,
            ).chain(CurveTween(curve: Curves.easeOutQuad)),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 0.08,
              end: 0.0,
            ).chain(CurveTween(curve: Curves.easeInOutQuad)),
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.30, 0.65),
          ),
        );

    // 3. Wordmark & Tagline: smooth slide and fade
    _textOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.70, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0.0, 0.10), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSplashSequence();
    });
  }

  Future<void> _startSplashSequence() async {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final animFuture = disableAnimations
        ? _controller.animateTo(1.0, duration: Duration.zero)
        : _controller.forward();

    final authFuture = _verifyAuth();

    await Future.wait([animFuture, authFuture]);

    _navigateToNextRoute();
  }

  Future<void> _verifyAuth() async {
    try {
      final authProvider = context.read<AuthProvider>();
      ProfileProvider? profileProvider;
      try {
        profileProvider = context.read<ProfileProvider>();
      } catch (_) {}
      ApiClient? apiClient;
      try {
        apiClient = context.read<ApiClient>();
      } catch (_) {}

      await authProvider.checkAuthStatus().timeout(widget.authTimeout);

      if (authProvider.isLoggedIn &&
          !authProvider.isAdmin &&
          profileProvider != null) {
        try {
          await profileProvider.loadProfile().timeout(
            const Duration(seconds: 4),
          );
          if (profileProvider.user != null) {
            authProvider.setCurrentUser(profileProvider.user!);
          }
        } catch (e) {
          debugPrint('[SplashScreen] Profile load fallback: $e');
        }
      } else if (!authProvider.isLoggedIn) {
        if (apiClient != null) {
          try {
            _hasCompletedOnboarding = await apiClient.hasCompletedOnboarding();
          } catch (_) {
            _hasCompletedOnboarding = false;
          }
        } else {
          _hasCompletedOnboarding = true;
        }
      }
    } catch (e) {
      debugPrint('[SplashScreen] Auth check fallback: $e');
    }
  }

  void _navigateToNextRoute() {
    if (!mounted || _isNavigating) return;
    _isNavigating = true;

    final authProvider = context.read<AuthProvider>();
    ProfileProvider? profileProvider;
    try {
      profileProvider = context.read<ProfileProvider>();
    } catch (_) {}

    final bool isProfileComplete =
        authProvider.isProfileComplete ||
        (profileProvider?.isProfileComplete ?? false);

    final String targetRoute;

    if (authProvider.isBiometricLocked) {
      // Session exists but protected by biometric lock
      targetRoute = AppRoutes.login;
    } else if (authProvider.isLoggedIn) {
      if (authProvider.isAdmin) {
        targetRoute = AppRoutes.adminDashboard;
      } else if (!isProfileComplete) {
        // MANDATORY ONBOARDING: User must complete physical biodata before accessing app
        targetRoute = AppRoutes.completeProfile;
      } else {
        targetRoute = AppRoutes.dashboard;
      }
    } else {
      targetRoute = _hasCompletedOnboarding
          ? AppRoutes.login
          : AppRoutes.onboarding;
    }

    Navigator.of(context).pushReplacementNamed(targetRoute);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompact = screenHeight < 650;
    final logoSize = isCompact ? 100.0 : 124.0;

    return Scaffold(
      backgroundColor: NeoTokens.canvas,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Logo Mark
                  ScaleTransition(
                    scale: _logoScale,
                    child: OopsieEatsLogoMark(
                      size: logoSize,
                      leafAngle: _leafAngle.value,
                    ),
                  ),
                  SizedBox(height: isCompact ? 6 : 8),

                  // 2. Editorial Wordmark & Tagline
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'OopsieEats',
                            style: TextStyle(
                              fontSize: isCompact ? 32 : 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.2,
                              height: 1.0,
                              color: NeoTokens.ink,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Know what's on your plate.",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                              color: NeoTokens.inkSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
