import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/core/theme/app_theme.dart';
import 'package:client/core/theme/workspace_accent.dart';
import 'package:client/features/kanban/ui/widgets/kanban_column.dart';
import 'package:client/features/shell/ui/widgets/desktop_sidebar_nav_item.dart';
import 'package:client/features/shell/ui/widgets/mobile_bottom_nav.dart';
import 'package:client/features/shell/ui/widgets/shell_top_bar.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/tasks/ui/widgets/my_tasks_section.dart';

void main() {
  group('Workspace Accent Visual Touchpoints', () {
    testWidgets(
      'ShellTopBar renders 2px accent hairline when activeWorkspaceAccent is set',
      (tester) async {
        tester.view.physicalSize = const Size(500, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(
              appBar: ShellTopBar(
                activeWorkspaceName: 'Acme Corp',
                activeWorkspaceAccent: 'orange',
              ),
            ),
          ),
        );

        final orangeColor = WorkspaceAccent.orange.resolvedColor(
          Brightness.dark,
        );
        expect(find.byType(ShellTopBar), findsOneWidget);

        // Verify gradient container with orange accent exists
        final containerFinder = find.byWidgetPredicate((widget) {
          if (widget is Container && widget.decoration is BoxDecoration) {
            final box = widget.decoration as BoxDecoration;
            if (box.gradient is LinearGradient) {
              final gradient = box.gradient as LinearGradient;
              return gradient.colors.contains(orangeColor);
            }
          }
          return false;
        });

        expect(containerFinder, findsOneWidget);
      },
    );

    testWidgets(
      'DesktopSidebarNavItem uses selectedAccentColor when selected',
      (tester) async {
        const testAccent = Color(0xFFF97316);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: DesktopSidebarNavItem(
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                isSelected: true,
                selectedAccentColor: testAccent,
                onTap: () {},
              ),
            ),
          ),
        );

        // Find the container with the accent wash and border
        final containerFinder = find.byWidgetPredicate((widget) {
          if (widget is Container && widget.decoration is BoxDecoration) {
            final box = widget.decoration as BoxDecoration;
            final hasWash = box.color == testAccent.withValues(alpha: 0.15);
            final hasBorder =
                box.border?.top.color == testAccent.withValues(alpha: 0.4);
            return hasWash && hasBorder;
          }
          return false;
        });

        expect(containerFinder, findsOneWidget);

        // Verify label text is tinted with testAccent
        final textWidget = tester.widget<Text>(find.text('Dashboard'));
        expect(textWidget.style?.color, testAccent);
      },
    );

    testWidgets(
      'MobileBottomNav highlights active item with activeWorkspaceAccent',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              bottomNavigationBar: MobileBottomNav(
                selectedIndex: 0,
                activeWorkspaceAccent: 'cyan',
                onItemSelected: (_) {},
              ),
            ),
          ),
        );

        final cyanColor = WorkspaceAccent.cyan.resolvedColor(Brightness.dark);

        // Find Text or Icon with the resolved cyan accent color
        final textFinder = find.byWidgetPredicate((widget) {
          if (widget is Text && widget.style?.color == cyanColor) {
            return true;
          }
          return false;
        });

        expect(textFinder, findsWidgets);
      },
    );

    testWidgets(
      'KanbanColumn renders top accent hairline and tints count badge',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(
              body: KanbanColumn(
                status: TaskStatus.todo,
                tasks: [],
                activeWorkspaceAccent: 'lime',
              ),
            ),
          ),
        );

        final limeColor = WorkspaceAccent.lime.resolvedColor(Brightness.dark);

        // Top hairline indicator
        final hairlineFinder = find.byWidgetPredicate((widget) {
          if (widget is Container && widget.decoration is BoxDecoration) {
            final box = widget.decoration as BoxDecoration;
            return box.color == limeColor.withValues(alpha: 0.8);
          }
          return false;
        });
        expect(hairlineFinder, findsOneWidget);

        // Count badge text color
        final countText = tester.widget<Text>(find.text('0'));
        expect(countText.style?.color, limeColor);
      },
    );

    testWidgets('MyTasksSection tints count badge with activeWorkspaceAccent', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: MyTasksSection(
              emoji: '📋',
              title: 'Up Next',
              tasks: [],
              isCollapsible: true,
              activeWorkspaceAccent: 'violet',
            ),
          ),
        ),
      );

      final violetColor = WorkspaceAccent.violet.resolvedColor(Brightness.dark);

      final countBadge = tester.widget<Text>(find.text('0'));
      expect(countBadge.style?.color, violetColor);
    });
  });
}
