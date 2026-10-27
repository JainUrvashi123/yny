import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/constants.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../widgets/onboarding_slide.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Discover Natural Brilliance',
      'description': 'Explore our exclusive collection of exquisitely crafted natural diamonds.',
      'icon': Icons.diamond_rounded,
    },
    {
      'title': 'Premium Quality Guaranteed',
      'description': 'Every stone is meticulously inspected and certified for authenticity and purity.',
      'icon': Icons.verified_rounded,
    },
    {
      'title': 'Your Perfect Jewelry Awaits',
      'description': 'Find the piece that speaks to you. Your journey to brilliance starts here.',
      'icon': Icons.favorite_rounded,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPageIndex < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background Glow Blobs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark 
                    ? AppConstants.accentColorDark.withOpacity(0.08) 
                    : AppConstants.accentColor.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark 
                    ? AppConstants.accentSecondary.withOpacity(0.05) 
                    : AppConstants.accentSecondary.withOpacity(0.03),
              ),
            ),
          ),

          // Main PageView
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _finishOnboarding,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _onboardingData.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return OnboardingSlide(
                        title: _onboardingData[index]['title'],
                        description: _onboardingData[index]['description'],
                        iconData: _onboardingData[index]['icon'],
                        isActive: _currentPageIndex == index,
                      );
                    },
                  ),
                ),
                
                // Bottom Navigation Area
                Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceXL),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dots Indicator
                      Row(
                        children: List.generate(
                          _onboardingData.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: _currentPageIndex == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPageIndex == index
                                  ? (isDark ? AppConstants.accentColorDark : AppConstants.accentColor)
                                  : (isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      
                      // Next/Get Started Button
                      ElevatedButton(
                        onPressed: _onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppConstants.accentColorDark : AppConstants.accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 4,
                          shadowColor: AppConstants.accentGlowColor,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentPageIndex == _onboardingData.length - 1 ? 'Get Started' : 'Next',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_currentPageIndex < _onboardingData.length - 1) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
