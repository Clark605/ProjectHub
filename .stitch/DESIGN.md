---
name: ProjectHub Deep Slate
colors:
  surface: '#13131B'
  surface-dim: '#13131B'
  surface-bright: '#393841'
  surface-container-lowest: '#0D0D15'
  surface-container-low: '#1B1B23'
  surface-container: '#1F1F27'
  surface-container-high: '#292932'
  surface-container-highest: '#34343D'
  on-surface: '#E4E1ED'
  on-surface-variant: '#908FA0'
  inverse-surface: '#F8FAFC'
  inverse-on-surface: '#0F172A'
  outline: '#334155'
  outline-variant: '#464554'
  surface-tint: '#C0C1FF'
  primary: '#C0C1FF'
  on-primary: '#1000A9'
  primary-container: '#8083FF'
  on-primary-container: '#0D0096'
  inverse-primary: '#8083FF'
  secondary: '#89CEFF'
  on-secondary: '#00344D'
  secondary-container: '#00A2E6'
  on-secondary-container: '#00344D'
  tertiary: '#38BDF8'
  on-tertiary: '#0F172A'
  tertiary-container: '#00A2E6'
  on-tertiary-container: '#00344D'
  error: '#FFB4AB'
  on-error: '#690005'
  error-container: '#690005'
  on-error-container: '#FFB4AB'
  primary-fixed: '#EAEBFF'
  primary-fixed-dim: '#C0C1FF'
  on-primary-fixed: '#1000A9'
  on-primary-fixed-variant: '#0D0096'
  secondary-fixed: '#89CEFF'
  secondary-fixed-dim: '#38BDF8'
  on-secondary-fixed: '#00344D'
  on-secondary-fixed-variant: '#00A2E6'
  tertiary-fixed: '#89CEFF'
  tertiary-fixed-dim: '#38BDF8'
  on-tertiary-fixed: '#00344D'
  on-tertiary-fixed-variant: '#00A2E6'
  background: '#0F172A'
  on-background: '#E4E1ED'
  surface-variant: '#1F1F27'
  success: '#22C55E'
  on-success: '#FFFFFF'
  success-container: '#132E22'
  on-success-container: '#22C55E'
  warning: '#FBBF24'
  on-warning: '#1F1F27'
  info: '#89CEFF'
  on-info: '#00344D'
  priority-urgent: '#FB7185'
  priority-high: '#F43F5E'
  priority-medium: '#38BDF8'
  priority-low: '#94A3B8'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 57px
    fontWeight: '400'
    lineHeight: 64px
    letterSpacing: -0.25px
  display-md:
    fontFamily: Inter
    fontSize: 45px
    fontWeight: '400'
    lineHeight: 52px
    letterSpacing: '0'
  display-sm:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: '400'
    lineHeight: 44px
    letterSpacing: '0'
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: '0'
  headline-md:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: '0'
  headline-sm:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: '0'
  title-lg:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: '0'
  title-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
    letterSpacing: 0.15px
  title-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.1px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0.5px
  body-base:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0.25px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
    letterSpacing: 0.4px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.1px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.5px
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.5px
rounded:
  none: 0px
  xs: 4px
  sm: 8px
  md: 10px
  lg: 12px
  xl: 14px
  card: 18px
  hero: 28px
  pill: 20px
  full: 9999px
spacing:
  unit: 4px
  0: 0px
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 20px
  2xl: 24px
  3xl: 32px
  4xl: 40px
  5xl: 48px
  6xl: 56px
  7xl: 64px
  gutter: 16px
  margin-mobile: 16px
  margin-desktop: 32px
---

# Design System: ProjectHub (Stitch Deep Slate)

A comprehensive design system specification extracted directly from the ProjectHub client and design token codebase. This document formalizes the visual identity, tokens, component patterns, and layout principles for Stitch screen generation and multi-platform implementation.

---

## 1. Visual Theme & Atmosphere

ProjectHub embodies the **Stitch Deep Slate Cyberpunk-Modern** archetype — an atmospheric, dark-first visual architecture calibrated for high-velocity engineering teams, real-time collaboration, and agile project delivery. The canvas is grounded in deep, rich midnight slate (`#0F172A`) layered with subtle tonal gradations (`#0D0D15` through `#393841`), replacing flat darkness with dimensional surface depth. Floating above this foundation are luminous, ethereal orbital light fields — primary **Electric Violet** (`#C0C1FF`) and trailing **Sky Blue** (`#89CEFF`) — diffused through heavy Gaussian blurs (`sigma: 70px`) and responsive interactive pointer tracking.

The design philosophy marries technical precision with kinetic fluidity. Crisp 1px translucent borders (`rgba(255, 255, 255, 0.08)` to `#334155`), backdrop-filtered frosted glass cards (`sigma: 12px`), micro-blueprint coordinate grid patterns (`24px` grid), and vibrant status telemetry pills produce an interface that feels alive, responsive, and engineered for maximum focus. High-contrast typography in pure **Inter** ensures legibility across dense Kanban boards, real-time presence indicators, and sprint velocity charts.

---

## 2. Color Palette & Roles

Colors are organized functionally by semantic hierarchy and contrast intent across dark and light modes.

### Primary Foundation (Surfaces & Structural Canvas)

- **Deep Slate Canvas (`#0F172A`)** — Scaffold background, root workspace wrapper, immersive dark theme baseline.
- **Base Surface / Surface Dim (`#13131B`)** — Base sheet layer, persistent navigation rails, bottom sheets.
- **Surface Container Lowest (`#0D0D15`)** — Recessed containers, terminal views, code snippet blocks.
- **Surface Container Low (`#1B1B23`)** — Kanban column boards, secondary container backdrops, muted grouping surfaces.
- **Surface Container (`#1F1F27`)** — Default card backgrounds, form input fills, dropdown menus.
- **Surface Container High (`#292932`)** — Elevated task cards, dialog surfaces, interactive item tiles.
- **Surface Container Highest (`#34343D`)** — Container hover states, avatar placeholders, interactive borders.
- **Surface Bright (`#393841`)** — Elevated highlights, active pill outlines, floating badges.
- **Structural Border (`#334155`)** — 1px primary container borders, dividers, input outlines.
- **Border Variant (`#464554`)** — Secondary outlines, subtle inner borders, disabled borders.

*Light Theme Equivalents:* Canvas (`#F8FAFC`), Surface (`#FFFFFF`), Container (`#F1F5F9`), Border (`#E2E8F0`).

### Accent & Interactive

- **Electric Violet (`#C0C1FF`)** — Primary brand interactive accent, primary button fill, focus indicators, active tab selection.
- **Deep Navy On-Primary (`#1000A9`)** — High-contrast dark text/iconography rendered on Electric Violet buttons.
- **Electric Violet Container (`#8083FF`)** — Glow orb core, selected chip backgrounds, progress gradient start.
- **Electric Violet Container Text (`#0D0096`)** — Deep contrast text on violet pills and cursor badges.
- **Sky Blue (`#89CEFF`)** — Secondary brand accent, hyperlinks, orbital trailing glow, info callouts.
- **Deep Navy On-Secondary (`#00344D`)** — High-contrast text on Sky Blue elements.
- **Sky Blue Container / Cyan Accent (`#00A2E6`)** — High-energy sprint badges, progress gradient stop.

### Typography & Text Hierarchy

- **Soft High-Contrast White (`#E4E1ED`)** — Primary reading copy, card titles, section headings.
- **Muted Slate Outline (`#908FA0`)** — Subtitles, form field labels, secondary metadata, placeholder text (at 60% opacity).
- **Subtle Slate Metadata (`#64748B`)** — Inactive timestamps, keyboard shortcut hints, disabled text.
- **Contrast Button Text (`#1000A9` Dark / `#FFFFFF` Light)** — Primary CTA button text.

### Priority & Functional States

- **Urgent Priority (`#FB7185`)** — Rose badge, critical blocking issues, overdue indicators.
- **High Priority (`#F43F5E`)** — Vibrant coral badge, high-priority backlog items.
- **Medium Priority (`#38BDF8`)** — Sky blue badge, normal sprint tasks.
- **Low Priority (`#94A3B8`)** — Neutral slate badge, routine tasks and chores.
- **Success (`#22C55E`)** — Completed tasks, verified states, live presence dots, +42% velocity accents.
- **Success Container Dark (`#132E22`)** — Completed task card fill in dark mode.
- **Success Container Light (`#EBFDF2`)** — Completed task card fill in light mode.
- **Warning (`#FBBF24`)** — Amber badge, pending workspace invitations, cautionary alerts.
- **Error (`#FFB4AB`)** — Form validation errors, error banners, destructive action outlines.
- **On-Error Text (`#690005`)** — Deep red text on error badges and alert banners.
- **Info (`#89CEFF`)** — System notifications, tooltips, onboarding hints.

---

## 3. Typography Rules

The typography system is built upon **Inter** (`-apple-system`, `BlinkMacSystemFont`, `Segoe UI`, `sans-serif`), delivering geometric clarity, high x-height, and superior legibility on digital screens.

### Hierarchy & Weights

- **Display Large (57px / Regular 400 / Line Height: 64px / Tracking: -0.25px):** Hero banners, marketing onboarding headers.
- **Display Medium (45px / Regular 400 / Line Height: 52px):** Major view headers, splash introductions.
- **Display Small (36px / Regular 400 / Line Height: 44px):** Primary statistics, large metric callouts.
- **Headline Large (32px / SemiBold 600 / Line Height: 40px):** Page titles, primary dashboard headings.
- **Headline Medium (28px / SemiBold 600 / Line Height: 36px):** Modal dialog headers, workspace section headers.
- **Headline Small (24px / SemiBold 600 / Line Height: 32px):** Onboarding step titles, column group titles.
- **Title Large (22px / SemiBold 600 / Line Height: 28px):** Card group headers, board titles.
- **Title Medium (16px / Medium 500 / Line Height: 24px / Tracking: +0.15px):** Card titles, tab labels, list group titles.
- **Title Small (14px / Medium 500 / Line Height: 20px / Tracking: +0.10px):** Task titles, modal subtitles.
- **Body Large (16px / Regular 400 / Line Height: 24px / Tracking: +0.50px):** Long-form descriptions, documentation.
- **Body Medium (14px / Regular 400 / Line Height: 20px / Tracking: +0.25px):** Input text, general interface copy.
- **Body Small (12px / Regular 400 / Line Height: 16px / Tracking: +0.40px):** Form helper text, validation messages, metadata.
- **Label Large (14px / Medium 500 / Line Height: 20px / Tracking: +0.10px):** Button text, interactive link labels.
- **Label Medium (12px / SemiBold 600 / Line Height: 16px / Tracking: +0.50px):** Form field labels, column counters, tag text.
- **Label Small (11px / Bold 700 / Line Height: 14px / Tracking: +0.50px):** Micro status badges, sprint velocity pills, avatar counters.

### Spacing Principles

- **Tight Display Spacing:** Display & Headline styles use neutral or slightly negative letter-spacing for punchy visual weight.
- **Open Micro-Labels:** Small uppercase labels (`Label Small`, `Label Medium`) utilize `+0.50px` tracking to ensure readability at 9–12px sizes.
- **Comfortable Line Heights:** Body copy maintains a 1.4–1.5× line-height ratio for relaxed comprehension during extended work sessions.

---

## 4. Component Stylings

### Buttons (`AppButton`)

- **Primary Button:**
  - Fill: Electric Violet (`#C0C1FF`)
  - Label: Deep Navy (`#1000A9`), Inter 15px, Bold (w700), Letter Spacing: 0.2px
  - Dimensions: Full width or auto, 52px fixed height, 12px border radius
  - Elevation: 0 (flat with ambient background interaction)
  - Loading State: Integrated 20×20 circular progress indicator (stroke: 2px)
- **Secondary Button:**
  - Fill: `#1F1F27` (Dark) / `#F1F5F9` (Light)
  - Border: 1px `#334155` (Dark) / `#E2E8F0` (Light)
  - Label: `#E4E1ED` (Dark) / `#0F172A` (Light), 15px, Bold (w700)
  - Dimensions: 52px height, 12px radius
- **Outline Button:**
  - Fill: Transparent
  - Border: 1px solid `#C0C1FF`
  - Label: `#C0C1FF`, 15px, Bold (w700)
- **Text Button:**
  - Fill: Transparent
  - Label: `#C0C1FF`, 14–15px, SemiBold

### Inputs & Forms (`AppTextField`)

- **Container:** `#1F1F27` fill (Dark) / `#F1F5F9` (Light), 12px border radius, 16px horizontal and vertical padding.
- **Borders:**
  - Default: 1px `#334155`
  - Focused: 1.5px solid `#C0C1FF` (Electric Violet focus halo)
  - Error: 1.5px to 2.0px solid `#FFB4AB`
- **Label:** `labelMedium` (12px), SemiBold 600, `#908FA0`, placed 8px above input container.
- **Hint Text:** `bodyMedium` (14px), `#908FA0` at 60% opacity.
- **Suffix / Password Toggle:** Interactive icon button with 200ms scale transition on visibility toggle.

### Cards & Visual Containers (`VisualCanvasCard`)

- **Geometry:** 28px border radius, max-width 440px on mobile/onboarding, 1.2px border (`rgba(255, 255, 255, 0.12)`).
- **Glassmorphism:** Linear gradient (`rgba(41, 41, 50, 0.7)` to `rgba(27, 27, 35, 0.85)`) with 12px backdrop blur filter.
- **Coordinate Grid:** 24px step blueprint grid overlay rendered in `rgba(255, 255, 255, 0.035)`.
- **Corner Glows:** Top-right soft radial glow (`#C0C1FF`, 180px radius) and bottom-left radial glow (`#89CEFF`, 160px radius).

### Domain-Specific Components

#### 1. Ambient Glow Engine (`AmbientGlowBackground`)
- **Structure:** Fullscreen background shader pairing background color (`#0F172A`) with dual rotating radial gradients.
- **Orbital Kinetics:** 14-second continuous clockwise orbital cycle (`#C0C1FF` primary orb + `#89CEFF` trailing orb).
- **Interactive Pointer Light:** Mouse/touch follower smoothed with 0.08 interpolation factor.
- **Diffusion Filter:** Gaussian backdrop filter (`sigmaX: 70`, `sigmaY: 70`).

#### 2. Kanban Board & Task Cards
- **Column Header:** 6px status dot + uppercase title + task counter.
- **Column Container:** `#1B1B23` fill (Dark, 70% opacity), 14px radius, 1px border.
- **Task Card:** `#292932` surface (Dark, 95% opacity), 10px radius, 1px border (`rgba(255, 255, 255, 0.08)`), title, uppercase priority tag pill, and circular user avatar.
- **Flying Task Card Transition:** Real-time animated card flying between columns with dynamic completion state (`#132E22` background, `#22C55E` border, checkmark icon).
- **Sprint Velocity Floating Pill:** 20px radius pill with gradient fill (`#0284C7` → `#22C55E`), +42% velocity label, floating 1600ms vertical oscillation animation.

#### 3. Real-Time Collaboration Presence & Cursors
- **Live Team Presence Bar:** Top pill container displaying pulsing green status dot (`#22C55E`), online member count, and mini-avatar stack (`20px` circles).
- **Live Multi-User Cursors:** SVG mouse cursor arrow + colored username badge (`#C0C1FF` Alex / `#89CEFF` Sarah) + animated 3-dot typing indicator.
- **Sync Status Toast:** 14px pill with pulsing dot, `#22C55E` border, displaying real-time latency status.

---

## 5. Layout Principles

### Grid & Structure

- **Base Rhythm:** 4px geometric baseline grid.
- **Standard Spacing Scale:** `4px` (xs), `8px` (sm), `12px` (md), `16px` (lg - component padding), `20px` (xl), `24px` (2xl - section padding), `32px` (3xl - section margin), `48px` (5xl), `64px` (7xl).
- **Max Content Widths:**
  - Auth / Onboarding Cards: `440px`
  - Dialogs & Modals: `560px`
  - Workspace Content: `1400px`

### Responsive Breakpoints

- **Mobile (`< 768px`):**
  - Single-column vertical stacking
  - Full-width 52px primary action buttons
  - Bottom navigation bar (`#13131B` background, `#C0C1FF` selected item)
  - Swipeable tabbed Kanban column view
  - 16px horizontal page margins
- **Tablet (`768px - 1199px`):**
  - Left navigation rail
  - 2-column task and analytics layout
  - Centered dialog cards
  - 24px horizontal page margins
- **Desktop / Web (`>= 1200px`):**
  - Fixed 240px sidebar navigation
  - Full multi-column horizontal Kanban board
  - Persistent slide-over task detail sheets
  - 32px horizontal page margins

### Elevation & Depth Hierarchy

Depth is established through translucent layered surfaces and localized neon glow shadows rather than flat drop shadows:
1. **Level 0 (Canvas):** `#0F172A` Deep Slate scaffold with ambient orbital glow.
2. **Level 1 (Columns & Rails):** `#1B1B23` / `#13131B` (80% opacity) with 1px `#334155` border.
3. **Level 2 (Cards & Tiles):** `#292932` (95% opacity) with 1px border and subtle 16px ambient glow shadow (`rgba(192, 193, 255, 0.08)`).
4. **Level 3 (Floating Pills & Modals):** `#34343D` / Gradient fills with 20px radius, 10px blur glow shadow (`rgba(34, 197, 94, 0.35)` or `rgba(192, 193, 255, 0.25)`).

---

## 6. Design System Notes for Stitch Generation

### Language to Use

When authoring prompts for Stitch screen generation in this design system, incorporate these keywords:
- **Atmosphere:** "Stitch Deep Slate dark mode", "luminous electric violet and sky blue ambient lighting", "frosted glassmorphism card with 12px blur", "cyberpunk modern technical interface", "blueprint coordinate grid background".
- **Color Descriptors:** "Deep slate canvas #0F172A", "surface container #1F1F27", "electric violet primary CTA #C0C1FF with dark navy text #1000A9", "sky blue secondary accent #89CEFF", "emerald green success badges #22C55E", "rose urgent priority tag #FB7185".
- **Component Geometry:** "12px rounded input fields and buttons", "28px rounded hero canvas cards", "20px pill status badges", "1px crisp hairline borders".

### Color References

```css
--bg-canvas: #0F172A;
--bg-surface: #13131B;
--bg-card: #1F1F27;
--bg-card-elevated: #292932;
--border-subtle: #334155;
--accent-violet: #C0C1FF;
--accent-sky: #89CEFF;
--accent-green: #22C55E;
--accent-rose: #FB7185;
--text-primary: #E4E1ED;
--text-muted: #908FA0;
```

### Component Prompts

#### Prompt 1: Project Kanban Board Screen
> "A dark-mode agile Kanban board screen in Stitch Deep Slate design system (#0F172A canvas). Features a top header with workspace switcher, live presence avatar stack (AK, SR, DM) with pulsing emerald green online dot, and search bar. Three columns ('To Do', 'In Progress', 'Done') in #1B1B23 containers with 14px radius and 1px border #334155. Task cards in #292932 with 10px rounded corners, showing sprint tags, urgent rose tags #FB7185, task checklist progress, and assignee avatars. A floating velocity badge at top right with gradient #0284C7 to #22C55E showing '+42% Velocity'. Electric Violet #C0C1FF primary 'New Task' button with dark text #1000A9."

#### Prompt 2: Authentication / Login Screen
> "A modern dark authentication login screen for ProjectHub. Deep slate #0F172A background with dual orbital ambient glow in Electric Violet #C0C1FF and Sky Blue #89CEFF diffused by 70px blur. Centered frosted glass card (440px wide, 28px radius) with 1px border and blueprint grid texture. AppTextField inputs in #1F1F27 with 12px radius and #C0C1FF focus border. Electric Violet primary login button (52px height, 12px radius, bold dark text #1000A9). Social auth buttons in outline style. Typography in crisp Inter."

#### Prompt 3: Team Collaboration & Real-Time Discussion Screen
> "A real-time project collaboration feed screen. Deep slate background with live multiplayer presence banner at the top showing '5 Team Members Online' and avatar rings. Live cursor markers labeled 'Alex · Lead' in Electric Violet #C0C1FF and 'Sarah · Dev' in Sky Blue #89CEFF with typing bubble animation. Central frosted card with sprint discussion thread, PR status checkmarks in emerald green #22C55E, and instant WebSocket sync toast at the bottom."

### Incremental Iteration

- Keep container backgrounds within the `#13131B` to `#292932` slate spectrum — avoid stark black `#000000` or washed-out greys.
- Maintain high contrast between Electric Violet buttons (`#C0C1FF`) and text (`#1000A9`).
- Ensure all interactive elements feature 12px border radius, while status tags and metric badges use 20px pill shapes.

