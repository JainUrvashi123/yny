import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/constants.dart';

class OnboardingSlide extends StatefulWidget {
  final String title;
  final String description;
  final IconData iconData;
  final bool isActive; // True if this slide is currently focused

  const OnboardingSlide({
    super.key,
    required this.title,
    required this.description,
    required this.iconData,
    required this.isActive,
  });

  @override
  State<OnboardingSlide> createState() => _OnboardingSlideState();
}

class _OnboardingSlideState extends State<OnboardingSlide> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant OnboardingSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0.0);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spaceXL),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
                  boxShadow: AppConstants.glassShadow,
                  border: Border.all(
                    color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
                  ),
                ),
                child: Icon(
                  widget.iconData,
                  size: 80,
                  color: isDark ? AppConstants.accentColorDark : AppConstants.accentColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceXXL),
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMD),
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                widget.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
