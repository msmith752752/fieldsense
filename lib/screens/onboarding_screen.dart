// onboarding_screen.dart
// No import of home_screen — uses onComplete callback instead.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  const OnboardingScreen({super.key, this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.agriculture_outlined,
      title: 'Stop guessing.\nStart knowing.',
      subtitle: 'FieldSense analyzes real rainfall data and gives you one clear answer every morning:\n\nWhat should I do in my field today?',
      highlight: null,
    ),
    _OnboardingPage(
      icon: Icons.water_drop_outlined,
      title: 'Real data.\nYour field.',
      subtitle: 'We track rainfall history, soil moisture, upcoming weather, and your crop\'s growth stage — all in one place.',
      highlight: null,
    ),
    _OnboardingPage(
      icon: Icons.check_circle_outline,
      title: 'Your daily verdict.',
      subtitle: 'Every morning, FieldSense tells you:\n\n"Good working window — plan field operations today."\n\nor\n\n"Stay out — saturated conditions with more rain coming."',
      highlight: null,
    ),
    _OnboardingPage(
      icon: Icons.my_location_rounded,
      title: 'Ready in 60 seconds.',
      subtitle: 'Tap + to add your field.\nWe\'ll detect your location automatically.\nPick your crop and soil type.\nThat\'s it.',
      highlight: 'Let\'s get started →',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text('Skip', style: TextStyle(color: Color(0xFF546E7A), fontSize: 14)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF4A90D9).withOpacity(0.1),
                            border: Border.all(color: const Color(0xFF4A90D9).withOpacity(0.2), width: 1),
                          ),
                          child: Icon(page.icon, size: 36, color: const Color(0xFF4A90D9)),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w300,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF78909C), fontSize: 15, height: 1.7),
                        ),
                        if (page.highlight != null) ...[
                          const SizedBox(height: 24),
                          Text(page.highlight!, style: const TextStyle(color: Color(0xFF4A90D9), fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? const Color(0xFF4A90D9) : const Color(0xFF1E2D3D),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    } else {
                      _completeOnboarding();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90D9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'Next' : 'Add My First Field',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? highlight;
  _OnboardingPage({required this.icon, required this.title, required this.subtitle, this.highlight});
}