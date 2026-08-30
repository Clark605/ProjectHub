import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:client/core/di/injection.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onGetStarted() {
    getIt<PrefsService>().setOnboardingSeen();
    Navigator.pushReplacementNamed(context, RouteNames.login);
  }

  void _onNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<Map<String, String>> onboardingData = [
      {
        'title': l10n.onboardingWelcomeTitle,
        'description': l10n.onboardingWelcomeDesc,
        'image': 'assets/images/onboarding_workspaces.jpg',
      },
      {
        'title': l10n.onboardingKanbanTitle,
        'description': l10n.onboardingKanbanDesc,
        'image': 'assets/images/onboarding_kanban.jpg',
      },
      {
        'title': l10n.onboardingCollabTitle,
        'description': l10n.onboardingCollabDesc,
        'image': 'assets/images/onboarding_collaboration.jpg',
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: onboardingData.length,
                    itemBuilder: (context, index) {
                      final data = onboardingData[index];
                      return Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child:
                                  Image.asset(
                                        data['image']!,
                                        fit: BoxFit.contain,
                                      )
                                      .animate()
                                      .fadeIn(duration: 500.ms)
                                      .scale(duration: 500.ms),
                            ),
                            const SizedBox(height: 40),
                            Text(
                                  data['title']!,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                )
                                .animate()
                                .fadeIn(delay: 200.ms)
                                .slideY(begin: 0.2, end: 0),
                            const SizedBox(height: 16),
                            Text(
                                  data['description']!,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                      ),
                                )
                                .animate()
                                .fadeIn(delay: 400.ms)
                                .slideY(begin: 0.2, end: 0),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          onboardingData.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      _currentPage == onboardingData.length - 1
                          ? ElevatedButton(
                              onPressed: _onGetStarted,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(120, 52),
                              ),
                              child: Text(l10n.getStarted),
                            ).animate().fadeIn().scale()
                          : TextButton(
                              onPressed: _onNext,
                              style: TextButton.styleFrom(
                                minimumSize: const Size(80, 52),
                              ),
                              child: Text(l10n.next),
                            ),
                    ],
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
