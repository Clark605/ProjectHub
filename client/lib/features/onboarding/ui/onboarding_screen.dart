import 'package:flutter/material.dart';
import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/core/widgets/ambient_glow_background.dart';
import 'package:client/features/onboarding/models/onboarding_step.dart';
import 'package:client/features/onboarding/ui/widgets/onboarding_bottom_bar.dart';
import 'package:client/features/onboarding/ui/widgets/onboarding_page_item.dart';
import 'package:client/features/onboarding/ui/widgets/onboarding_top_bar.dart';
import 'package:client/features/onboarding/ui/widgets/visuals/collaboration_visual.dart';
import 'package:client/features/onboarding/ui/widgets/visuals/kanban_visual.dart';
import 'package:client/features/onboarding/ui/widgets/visuals/workspace_visual.dart';
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

  void _onSkip() {
    getIt<PrefsService>().setOnboardingSeen();
    Navigator.pushReplacementNamed(context, RouteNames.login);
  }

  void _onNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onDotTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final List<OnboardingStep> onboardingData = [
      OnboardingStep(
        badgeText: l10n.onboardingTagWorkspaces,
        title: l10n.onboardingWelcomeTitle,
        description: l10n.onboardingWelcomeDesc,
        visual: const WorkspaceVisual(),
      ),
      OnboardingStep(
        badgeText: l10n.onboardingTagKanban,
        title: l10n.onboardingKanbanTitle,
        description: l10n.onboardingKanbanDesc,
        visual: const KanbanVisual(),
      ),
      OnboardingStep(
        badgeText: l10n.onboardingTagCollab,
        title: l10n.onboardingCollabTitle,
        description: l10n.onboardingCollabDesc,
        visual: const CollaborationVisual(),
      ),
    ];

    final isLastPage = _currentPage == onboardingData.length - 1;

    return AmbientGlowBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  OnboardingTopBar(
                    onSkip: _onSkip,
                    isLastPage: isLastPage,
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemCount: onboardingData.length,
                      itemBuilder: (context, index) {
                        final step = onboardingData[index];
                        return RepaintBoundary(
                          child: OnboardingPageItem(
                            tag: step.badgeText,
                            title: step.title,
                            description: step.description,
                            visual: step.visual,
                          ),
                        );
                      },
                    ),
                  ),
                  OnboardingBottomBar(
                    currentPage: _currentPage,
                    totalPages: onboardingData.length,
                    onNext: _onNext,
                    onGetStarted: _onGetStarted,
                    onDotTap: _onDotTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
