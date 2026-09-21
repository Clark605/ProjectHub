import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/onboarding/ui/widgets/visuals/visual_canvas_card.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanVisual extends StatefulWidget {
  const KanbanVisual({super.key});

  @override
  State<KanbanVisual> createState() => _KanbanVisualState();
}

class _KanbanVisualState extends State<KanbanVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cardFlyController;

  @override
  void initState() {
    super.initState();
    _cardFlyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _cardFlyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final columnBg = isDark
        ? AppColors.surfaceContainerLow.withValues(alpha: 0.7)
        : AppColors.lightSurfaceContainer;
    final cardBg = isDark
        ? AppColors.surfaceContainerHigh.withValues(alpha: 0.95)
        : Colors.white;
    final cardBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.lightBorder;

    return VisualCanvasCard(
      primaryGlow: AppColors.skyBlue,
      secondaryGlow: AppColors.electricViolet,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Kanban Columns Grid ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildColumnHeader(
                    l10n?.statusTodo.toUpperCase() ?? 'TO DO',
                    '2',
                    AppColors.priorityUrgent,
                    theme,
                  ),
                  const SizedBox(width: 8),
                  _buildColumnHeader(
                    l10n?.statusInProgress.toUpperCase() ?? 'IN PROGRESS',
                    '3',
                    AppColors.electricViolet,
                    theme,
                  ),
                  const SizedBox(width: 8),
                  _buildColumnHeader(
                    l10n?.statusDone.toUpperCase() ?? 'DONE',
                    '8',
                    AppColors.success,
                    theme,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Columns Container
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Col 1: TO DO
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: columnBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Column(
                        children: [
                          _buildTaskCard(
                            title: 'JWT Refresh',
                            tag: l10n?.priorityUrgent.toUpperCase() ?? 'URGENT',
                            tagColor: AppColors.priorityUrgent,
                            avatarInitials: 'EL',
                            cardBg: cardBg,
                            cardBorder: cardBorder,
                            theme: theme,
                          ),
                          const SizedBox(height: 6),
                          _buildDottedPlaceholder(cardBorder),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Col 2: IN PROGRESS
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: columnBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.electricViolet.withValues(alpha: 0.25)
                              : AppColors.electricViolet.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildTaskCard(
                            title: 'Drag & Drop UI',
                            tag: 'FRONTEND',
                            tagColor: AppColors.electricViolet,
                            avatarInitials: 'MK',
                            cardBg: cardBg,
                            cardBorder: cardBorder,
                            theme: theme,
                          ),
                          const SizedBox(height: 6),
                          _buildDottedPlaceholder(cardBorder),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Col 3: DONE
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: columnBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Column(
                        children: [
                          _buildCompletedTaskCard(
                            title: 'DB Schema',
                            cardBg: cardBg,
                            cardBorder: cardBorder,
                            theme: theme,
                          ),
                          const SizedBox(height: 6),
                          _buildCompletedTaskCard(
                            title: 'CI/CD Pipeline',
                            cardBg: cardBg,
                            cardBorder: cardBorder,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Animated Flying Card that transitions from In Progress to Done ──
          AnimatedBuilder(
            animation: _cardFlyController,
            builder: (context, child) {
              final val = _cardFlyController.value;
              // Timeline:
              // 0.0 - 0.25: resting in In Progress
              // 0.25 - 0.65: flying smoothly from In Progress to Done column
              // 0.65 - 0.90: glow + checkmark burst in Done column
              // 0.90 - 1.00: fade out and loop
              double slideT = 0;
              if (val > 0.25 && val <= 0.65) {
                slideT = Curves.easeInOutCubic.transform((val - 0.25) / 0.40);
              } else if (val > 0.65) {
                slideT = 1.0;
              }

              final opacity = val > 0.92 ? ((1.0 - val) / 0.08) : 1.0;
              final isDoneState = val >= 0.65;

              return Positioned(
                bottom: 22,
                left: 125 + (slideT * 120),
                child: RepaintBoundary(
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: (slideT * 0.04) * (slideT < 1.0 ? 1 : 0),
                      child: Container(
                        width: 105,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isDoneState
                              ? (isDark
                                    ? const Color(0xFF132E22)
                                    : const Color(0xFFEBFDF2))
                              : cardBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDoneState
                                ? AppColors.success
                                : AppColors.electricViolet,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDoneState
                                  ? AppColors.success.withValues(alpha: 0.35)
                                  : AppColors.electricViolet.withValues(
                                      alpha: 0.25,
                                    ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Telemetry',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Icon(
                                  isDoneState
                                      ? Icons.check_circle_rounded
                                      : Icons.swap_horiz_rounded,
                                  size: 12,
                                  color: isDoneState
                                      ? AppColors.success
                                      : AppColors.electricViolet,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDoneState
                                        ? AppColors.success.withValues(
                                            alpha: 0.2,
                                          )
                                        : AppColors.electricViolet.withValues(
                                            alpha: 0.15,
                                          ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isDoneState
                                        ? (l10n?.statusDone.toUpperCase() ??
                                            'DONE')
                                        : 'SYNC',
                                    style: TextStyle(
                                      color: isDoneState
                                          ? AppColors.success
                                          : AppColors.electricViolet,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.skyBlue,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'JD',
                                      style: TextStyle(
                                        fontSize: 7,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // ── Floating Sprint Velocity Badge ──
          Positioned(
            top: -10,
            right: 4,
            child: RepaintBoundary(
              child:
                  Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0284C7), Color(0xFF22C55E)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.trending_up_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Sprint 14 · 92% Done',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true),
                      )
                      .moveY(
                        begin: 0,
                        end: -4,
                        duration: 1600.ms,
                        curve: Curves.easeInOut,
                      )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 350.ms)
                      .scale(
                        duration: 400.ms,
                        delay: 350.ms,
                        curve: Curves.easeOutBack,
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(
    String name,
    String count,
    Color dotColor,
    ThemeData theme,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  name,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            Text(
              count,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: dotColor,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String tag,
    required Color tagColor,
    required String avatarInitials,
    required Color cardBg,
    required Color cardBorder,
    required ThemeData theme,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: tagColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tagColor.withValues(alpha: 0.8),
                ),
                child: Center(
                  child: Text(
                    avatarInitials,
                    style: const TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTaskCard({
    required String title,
    required Color cardBg,
    required Color cardBorder,
    required ThemeData theme,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 10,
                decoration: TextDecoration.lineThrough,
                color: theme.textTheme.labelSmall?.color?.withValues(
                  alpha: 0.5,
                ),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            size: 13,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildDottedPlaceholder(Color borderColor) {
    return Container(
      height: 28,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.5),
          style: BorderStyle.solid,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.add_rounded,
          size: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
