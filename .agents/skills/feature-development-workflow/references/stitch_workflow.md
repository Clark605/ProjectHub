# Stitch MCP UI Design & Token Extraction Guide

This guide details how to use **Stitch MCP** tools to design screens, extract UI layouts, and map design tokens into Flutter code for ProjectHub.

---

## 🛠 Available Stitch MCP Tools

| Tool | Purpose | Example Usage |
| :--- | :--- | :--- |
| `generate_screen_from_text` | Generates a new UI screen mockup based on prompt | Ideating task detail sheet or analytics charts |
| `get_screen` | Retrieves screen details and layout structure | Inspecting components of a generated screen |
| `list_screens` | Lists screens created in a project | Browsing existing UI designs |
| `create_project` | Creates a new Stitch design project | Initializing a new feature workspace |
| `create_design_system` | Defines design tokens (colors, typography, radii) | Standardizing theme tokens |
| `generate_variants` | Generates visual variations of a screen | Comparing mobile vs widescreen layouts |

---

## 🎨 Token Mapping to ProjectHub Theme

When designing or inspecting Stitch screens, map visual elements directly to the constants in `client/lib/core/theme/`:

```dart
// client/lib/core/theme/app_colors.dart
class AppColors {
  // Backgrounds & Surfaces
  static const Color background = Color(0xFF0F172A);          // Deep Slate
  static const Color surface = Color(0xFF13131B);             // Elevated Surface
  static const Color surfaceContainer = Color(0xFF1E293B);    // Card Container
  static const Color surfaceContainerHigh = Color(0xFF292932);// Modal & Sheets
  static const Color border = Color(0xFF334155);              // Subtle Borders

  // Brand Accents
  static const Color primary = Color(0xFF6366F1);             // Indigo Primary
  static const Color primaryContainer = Color(0xFF8083FF);    // Light Indigo
  static const Color secondary = Color(0xFF38BDF8);           // Sky Blue Accent

  // Priority Tokens
  static const Color priorityUrgent = Color(0xFFFB7185);      // Rose
  static const Color priorityHigh = Color(0xFFF43F5E);        // Coral
  static const Color priorityMedium = Color(0xFF38BDF8);      // Sky
  static const Color priorityLow = Color(0xFF94A3B8);         // Slate
}
```

---

## 📋 Recommended Workflow Steps

1. **Ideation:** When a new screen is needed, call `generate_screen_from_text` on Stitch MCP with descriptive requirements (e.g. *"A Kanban board task detail slide-over sheet with priority badges, assignee selector, and subtask checklist in dark mode"*).
2. **Structural Extraction:** Examine the generated layout hierarchy to determine widget decomposition (e.g. Header, Body sections, Actions bar).
3. **Flutter Implementation:** Write clean Flutter widgets composing existing atoms from `core/widgets/` (such as `GlassCard`, `PrimaryButton`, `PriorityChip`) styled with `AppColors`.
4. **Responsive Breakouts:** Adapt for Mobile (`<768px`) using BottomSheets/Tabs and Desktop (`≥1200px`) using Slide-over side-sheets.

