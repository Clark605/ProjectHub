import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/ambient_glow_background.dart';
import 'package:client/features/onboarding/ui/widgets/onboarding_bottom_bar.dart';
import 'package:client/features/onboarding/ui/widgets/onboarding_page_item.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, dynamic>> onboardingData = [
      {
        'tag': l10n.onboardingTagWorkspaces,
        'title': l10n.onboardingWelcomeTitle,
        'description': l10n.onboardingWelcomeDesc,
        'visual': const WorkspaceVisual(),
      },
      {
        'tag': l10n.onboardingTagKanban,
        'title': l10n.onboardingKanbanTitle,
        'description': l10n.onboardingKanbanDesc,
        'visual': const KanbanVisual(),
      },
      {
        'tag': l10n.onboardingTagCollab,
        'title': l10n.onboardingCollabTitle,
        'description': l10n.onboardingCollabDesc,
        'visual': const CollaborationVisual(),
      },
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
                  // ── Top Bar with Logo & Skip ──
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Brand Logo Pill
                        Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.electricViolet.withValues(
                                      alpha: 0.18,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.electricViolet
                                          .withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.hub_rounded,
                                    size: 18,
                                    color: AppColors.electricViolet,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  l10n.appTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                    color: isDark
                                        ? AppColors.textPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ],
                            )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: -0.1, end: 0),

                        // Skip Action Button
                        AnimatedOpacity(
                              opacity: isLastPage ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 250),
                              child: IgnorePointer(
                                ignoring: isLastPage,
                                child: TextButton(
                                  onPressed: _onSkip,
                                  style: TextButton.styleFrom(
                                    foregroundColor: isDark
                                        ? AppColors.textSecondary
                                        : AppColors.lightTextSecondary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.skip,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: 0.1, end: 0),
                      ],
                    ),
                  ),

                  // ── Main PageView Carousel ──
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemCount: onboardingData.length,
                      itemBuilder: (context, index) {
                        final data = onboardingData[index];
                        return RepaintBoundary(
                          child: OnboardingPageItem(
                            tag: data['tag'] as String,
                            title: data['title'] as String,
                            description: data['description'] as String,
                            visual: data['visual'] as Widget,
                          ),
                        );
                      },
                    ),
                  ),

                  // ── Dynamic Bottom Bar ──
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
