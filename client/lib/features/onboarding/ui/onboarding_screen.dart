import 'package:flutter/material.dart';
import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/features/onboarding/ui/widgets/onboarding_bottom_bar.dart';
import 'package:client/features/onboarding/ui/widgets/onboarding_page_item.dart';
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
                      setState(() => _currentPage = index);
                    },
                    itemCount: onboardingData.length,
                    itemBuilder: (context, index) {
                      final data = onboardingData[index];
                      return OnboardingPageItem(
                        title: data['title']!,
                        description: data['description']!,
                        imagePath: data['image']!,
                      );
                    },
                  ),
                ),
                OnboardingBottomBar(
                  currentPage: _currentPage,
                  totalPages: onboardingData.length,
                  onNext: _onNext,
                  onGetStarted: _onGetStarted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
