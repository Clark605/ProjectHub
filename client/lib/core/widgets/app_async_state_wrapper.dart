import 'package:flutter/material.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/core/widgets/app_empty_state.dart';
import 'package:client/core/widgets/app_error_state.dart';

/// Standard wrapper handling pull-to-refresh, full-screen errors, empty states, and content.
class AppAsyncStateWrapper extends StatelessWidget {
  const AppAsyncStateWrapper({
    super.key,
    required this.onRefresh,
    required this.child,
    this.errorMessage,
    this.isEmpty = false,
    this.emptyTitle,
    this.emptyDescription,
    this.emptyIcon,
    this.emptyCtaText,
    this.onEmptyCtaPressed,
    this.padding,
    this.errorPadding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.xxl,
    ),
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final String? errorMessage;
  final bool isEmpty;
  final String? emptyTitle;
  final String? emptyDescription;
  final IconData? emptyIcon;
  final String? emptyCtaText;
  final VoidCallback? onEmptyCtaPressed;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry errorPadding;

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: errorPadding,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: AppErrorState(
              errorMessage: errorMessage!,
              onRetry: onRefresh,
            ),
          ),
        ),
      );
    }

    if (isEmpty && emptyTitle != null) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Center(
              child: AppEmptyState(
                icon: emptyIcon ?? Icons.inbox_outlined,
                title: emptyTitle!,
                description: emptyDescription ?? '',
                ctaText: emptyCtaText,
                onCtaPressed: onEmptyCtaPressed,
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        child: child,
      ),
    );
  }
}
