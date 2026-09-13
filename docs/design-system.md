# ProjectHub — Design System Specification

A comprehensive reference for the **Stitch Deep Slate Design System** utilized across ProjectHub Flutter client, Web, and presentations.

---

## 1. System Overview & Aesthetic Archetype

- **Design Philosophy:** Stitch Deep Slate Cyberpunk-Modern — high-contrast, dark-first foundation with luminous neon accents (Electric Violet & Sky Blue), subtle orbital glow fields, and glassmorphism.
- **Base Architecture:** Three-Layer Design Token Hierarchy (Primitive → Semantic → Component) aligned with W3C DTCG.
- **Color Engine:** Dual-mode (Dark theme baseline with full Light Theme counterpart).
- **Typography:** Bundled **Inter** font family with Material 3 typography scale.

---

## 2. Token Architecture

```
┌──────────────────────────────────────────────────────────┐
│  Component Tokens                                        │  Per-component overrides
│  --button-primary-bg, --input-focus-border, --card-bg    │
├──────────────────────────────────────────────────────────┤
│  Semantic Tokens                                         │  Purpose-based aliases & roles
│  --color-primary, --color-surface, --color-border        │
├──────────────────────────────────────────────────────────┤
│  Primitive Tokens                                        │  Raw design primitives
│  --primitive-color-slate-900, --primitive-spacing-4       │
└──────────────────────────────────────────────────────────┘
```

---

## 3. Color Palette & Token Maps

### 3.1 Dark Foundation (Primary)

| Token Name | Hex Code | Purpose / Usage |
| :--- | :---: | :--- |
| `background` | `#0F172A` | Deep Slate canvas scaffold background |
| `surface` / `surfaceDim` | `#13131B` | Base surface for sheets, navigation rails |
| `surfaceContainerLowest` | `#0D0D15` | Recessed backgrounds, code blocks |
| `surfaceContainerLow` | `#1B1B23` | Column backgrounds, subtle containers |
| `surfaceContainer` | `#1F1F27` | Cards, input fields, dropdown menus |
| `surfaceContainerHigh` | `#292932` | Elevated cards, Kanban task cards |
| `surfaceContainerHighest` | `#34343D` | Hover states on containers |
| `surfaceBright` | `#393841` | Elevated highlights, pill borders |
| `border` | `#334155` | 1px standard structural borders |
| `borderVariant` | `#464554` | Secondary outlines and subtle dividers |

### 3.2 Accents & Brand Roles

| Token Name | Hex Code | Purpose / Usage |
| :--- | :---: | :--- |
| `electricViolet` (`primary`) | `#C0C1FF` | Main brand interactive accent, CTA fill, active indicators |
| `electricVioletContainer` (`primaryContainer`) | `#8083FF` | Secondary violet glow orb, selected chip fills |
| `onElectricViolet` (`textOnPrimary`) | `#1000A9` | High-contrast dark text on Electric Violet buttons |
| `onElectricVioletContainer` | `#0D0096` | Deep contrast text on container elements |
| `skyBlue` (`secondary`) | `#89CEFF` | Secondary brand accent, hyperlinks, orbital trailing glow |
| `skyBlueContainer` (`secondaryContainer`) | `#00A2E6` | High-energy cyan accent, gradient stops |
| `onSkyBlue` | `#00344D` | Dark navy text for sky blue fills |

### 3.3 Priority Tokens

| Priority Level | Hex Code | Preview / Accent |
| :--- | :---: | :--- |
| **Urgent** | `#FB7185` | Rose / Pink-Red accent badge |
| **High** | `#F43F5E` | Coral / Vibrant Red badge |
| **Medium** | `#38BDF8` | Sky Blue badge |
| **Low** | `#94A3B8` | Slate Grey badge |

### 3.4 Feedback & Status Tokens

| Status | Hex Code | Role |
| :--- | :---: | :--- |
| **Success** | `#22C55E` | Emerald Green — completed tasks, verified states |
| **Success Dark** | `#132E22` | Dark green background for completed card states |
| **Success Light** | `#EBFDF2` | Light green background for completed badge states |
| **Warning** | `#FBBF24` | Amber — pending invites, cautionary alerts |
| **Error** | `#FFB4AB` | Light Coral / Red — form errors, validation banners |
| **On Error** | `#690005` | Deep red text for error chips |
| **Info** | `#89CEFF` | Informational callouts and tooltips |

### 3.5 Text Hierarchy

| Token | Dark Mode | Light Mode | Description |
| :--- | :---: | :---: | :--- |
| `textPrimary` | `#E4E1ED` | `#0F172A` | Soft high-contrast primary reading text |
| `textSecondary` | `#908FA0` | `#475569` | Muted subtitle, input label, secondary text |
| `textTertiary` | `#64748B` | `#94A3B8` | Metadata, disabled text, placeholder hints |
| `textOnPrimary` | `#1000A9` | `#FFFFFF` | Text rendered on primary buttons |

### 3.6 Workspace-Scoped Accent Colors (Phase 4.5 & ADR-0015)

Per [ADR-0015](./adr/0015-workspace-accent-color-replaces-personal-palette.md), ProjectHub locks its core visual design permanently to the **Deep Slate** brand identity (Electric Violet `#C0C1FF` and Sky Blue `#89CEFF` on Deep Slate dark surfaces `#0F172A`/`#1F1F27`, with calibrated Light theme counterparts), preserving the signature `AmbientGlowBackground` driven by fixed brand colors.

In place of global theming, each workspace is assigned a server-owned **Accent Color** chosen from a curated, high-contrast 10-color palette used exclusively for wayfinding signals (switcher pill indicator dot, active sidebar stripe, and workspace switcher list items):

| Accent ID | Name | Dark Mode Color | Light Mode Color | Vibe / Personality |
| :--- | :--- | :---: | :---: | :--- |
| `teal` | Teal *(Default)* | `#14B8A6` | `#0D9488` | Calm, modern |
| `blue` | Blue | `#3B82F6` | `#2563EB` | Classic, professional |
| `indigo` | Indigo | `#6366F1` | `#4F46E5` | Deep, focused |
| `violet` | Violet | `#8B5CF6` | `#7C3AED` | Creative, bold |
| `pink` | Pink | `#EC4899` | `#DB2777` | Vibrant, energetic |
| `rose` | Rose | `#F43F5E` | `#E11D48` | Warm, assertive |
| `orange` | Orange | `#F97316` | `#EA580C` | Energetic, playful |
| `amber` | Amber | `#F59E0B` | `#D97706` | Warm, welcoming |
| `lime` | Lime | `#84CC16` | `#65A30D` | Fresh, natural |
| `cyan` | Cyan | `#06B6D4` | `#0891B2` | Cool, technical |

- **Strict Boundary Isolation:** Workspace accent colors flow strictly as widget parameters and never pollute global `ThemeData`, `ColorScheme`, surface containers, action buttons, cards, typography, or semantic status dots.
- **Role Enforcement:** Only the workspace `Owner` can alter the workspace accent color via the inline picker in `WorkspaceDetailsCard`.

---

## 4. Typography Scale

- **Font Family:** `Inter`, `-apple-system`, `BlinkMacSystemFont`, `Segoe UI`, `sans-serif`

| Style | Font Size | Weight | Line Height / Spacing |
| :--- | :---: | :---: | :--- |
| `displayLarge` | 57px | 400 (Regular) | Letter-spacing: -0.25px |
| `displayMedium` | 45px | 400 (Regular) | Standard |
| `displaySmall` | 36px | 400 (Regular) | Standard |
| `headlineLarge` | 32px | 600 (SemiBold) | Standard |
| `headlineMedium` | 28px | 600 (SemiBold) | Standard |
| `headlineSmall` | 24px | 600 (SemiBold) | Standard |
| `titleLarge` | 22px | 600 (SemiBold) | Standard |
| `titleMedium` | 16px | 500 (Medium) | Letter-spacing: +0.15px |
| `titleSmall` | 14px | 500 (Medium) | Letter-spacing: +0.10px |
| `bodyLarge` | 16px | 400 (Regular) | Letter-spacing: +0.50px |
| `bodyMedium` | 14px | 400 (Regular) | Letter-spacing: +0.25px |
| `bodySmall` | 12px | 400 (Regular) | Letter-spacing: +0.40px |
| `labelLarge` | 14px | 500 (Medium) | Letter-spacing: +0.10px |
| `labelMedium` | 12px | 500 (Medium) | Letter-spacing: +0.50px |
| `labelSmall` | 11px | 500 (Medium) | Letter-spacing: +0.50px |

---

## 5. Spacing, Radii & Elevation

### 5.1 Spacing Scale (4px Base Grid)
- `0`: 0px
- `1`: 4px
- `2`: 8px
- `3`: 12px
- `4`: 16px (Standard component padding)
- `5`: 20px
- `6`: 24px (Standard section padding)
- `8`: 32px
- `10`: 40px
- `12`: 48px
- `14`: 56px
- `16`: 64px

### 5.2 Border Radii
- `xs` (4px): Checkboxes, micro-tags, status pills
- `sm` (8px): Chips, dropdown menus, dotted placeholders
- `md` (10px): Kanban cards, sub-containers
- `lg` (12px): Standard buttons, input fields, cards
- `xl` (14px): Kanban column boards, modal dialogs
- `pill` (20px): Velocity badges, floating counters
- `full` (9999px): User avatars, circular action buttons

### 5.3 Responsive Breakpoints
- **Mobile (`< 768px`):** Single-column layout, bottom navigation bar, swipeable column views, modal bottom sheets.
- **Tablet (`768px - 1199px`):** Navigation rail, 2-column task grids, centered dialogs.
- **Desktop / Web (`>= 1200px`):** Fixed 240px sidebar, full horizontal Kanban multi-column board, slide-over detail sheets.

---

## 6. Core Component Specifications

### 6.1 `AppButton`
- **Variants:**
  - `primary`: Background `#C0C1FF`, Foreground `#1000A9`, Border: None, Height: 52px, Radius: 12px, Weight: 700.
  - `secondary`: Background `#1F1F27`, Foreground `#E4E1ED`, Border: 1px `#334155`, Height: 52px, Radius: 12px.
  - `outline`: Background: Transparent, Foreground `#C0C1FF`, Border: 1px `#C0C1FF`, Height: 52px.
  - `text`: Background: Transparent, Foreground `#C0C1FF`, Padding: 16px.
- **Loading State:** Centered `CircularProgressIndicator` (20x20, strokeWidth: 2).

### 6.2 `AppTextField`
- **Fill:** `#1F1F27` (Dark) / `#F1F5F9` (Light)
- **Borders:**
  - Default: 1px `#334155`
  - Focused: 1.5px `#C0C1FF`
  - Error: 1.5px / 2.0px `#FFB4AB`
- **Label:** `labelMedium` w600 `#908FA0`
- **Hint:** `bodyMedium` `#908FA0` at 60% opacity
- **Suffix:** Interactive password visibility toggle with smooth 200ms scale transition.

### 6.3 `AmbientGlowBackground`
- **Structure:** Dual orbital gradient shader with interactive pointer follower and `sigma: 70` Gaussian blur.
- **Trajectory:** 14-second orbital cycle with primary orb (`#C0C1FF`) and trailing sky blue orb (`#89CEFF`).
- **Pointer Follower:** Responsive interactive follower light mapped dynamically to mouse/touch coordinates.

### 6.4 `KanbanVisual` / Task Cards
- **Column Header:** Dot status + title + counter.
- **Task Card:** `#292932` container, 10px radius, 1px border `rgba(255,255,255,0.08)`, priority tag, assignee avatar circle.
- **Completed Card:** Strikethrough text with `#22C55E` checkmark icon.
- **Velocity Pill:** Gradient `#0284C7` → `#22C55E`, floating animation, 20px radius.

---

## 7. Design Token Files

- **JSON Tokens (W3C DTCG format):** [`assets/design-tokens.json`](file:///d:/MyProgrammingProjects/DotnetProjects/ProjectHub.Api/assets/design-tokens.json)
- **Compiled CSS Variables:** [`assets/design-tokens.css`](file:///d:/MyProgrammingProjects/DotnetProjects/ProjectHub.Api/assets/design-tokens.css)
- **Flutter Theme Implementation:** [`client/lib/core/theme/`](file:///d:/MyProgrammingProjects/DotnetProjects/ProjectHub.Api/client/lib/core/theme/)

