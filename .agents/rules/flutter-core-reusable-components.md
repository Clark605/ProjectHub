---
trigger: always_on
---

# Flutter Core Reusable Components Rule

Always leverage the standardized, reusable components located in [`client/lib/core/`](client/lib/core/) whenever implementing, refactoring, or fixing Flutter features, UI, or state management logic. Do NOT create ad-hoc widgets, custom duplicate dialogs, raw snackbars, or unhandled async cubits when a core equivalent exists.

---

## 1. State Management: Safe Cubits

- **Base Class**: All Cubits executing asynchronous operations or handling API / network actions MUST extend [`SafeActionCubit<T>`](client/lib/core/cubit/safe_action_cubit.dart) (`client/lib/core/cubit/safe_action_cubit.dart`) instead of raw `Cubit<T>`.
- **Safe Execution**: Use `safeExecute<R>()` to run async actions:
  - Automatically catches [`AppException`](client/lib/core/errors/app_exception.dart) and standard exceptions.
  - Checks `isClosed` before state emissions to avoid "Cannot emit new states after calling close" crashes.
  - Automatically logs warnings and errors with contextual `logTag` via `AppLogger`.
  - Dispatches failure messages through the `onError` callback.

---

## 2. Dialogs & Bottom Sheets

- **Bottom Sheets**:
  - Always use [`showAppBottomSheet<T>()`](client/lib/core/dialog/app_bottom_sheet.dart) (`client/lib/core/dialog/app_bottom_sheet.dart`) for modals and action sheets on mobile.
  - Include [`AppSheetDragHandle`](client/lib/core/dialog/app_bottom_sheet.dart) at the top of the sheet content.
  - Include [`AppSheetHeader`](client/lib/core/dialog/app_bottom_sheet.dart) for title, subtitle, and close button consistency.
  - Do NOT call bare `showModalBottomSheet()` with inline custom shapes and colors.
- **Confirmation Dialogs**:
  - Always use [`showAppConfirmDialog()`](client/lib/core/dialog/app_confirm_dialog.dart) or [`AppConfirmDialog`](client/lib/core/dialog/app_confirm_dialog.dart) (`client/lib/core/dialog/app_confirm_dialog.dart`) for confirmations, destructive actions (e.g. deletion, discarding changes, leaving a workspace).
  - Do NOT create bespoke `AlertDialog` instances with custom action button rows.

---

## 3. Error Handling & Feedback UI

- **Full-Screen / Container Errors**:
  - Use [`AppErrorState`](client/lib/core/widgets/app_error_state.dart) (`client/lib/core/widgets/app_error_state.dart`) when a view, tab, or screen fails to load data. Provide the `errorMessage` and the `onRetry` callback.
- **Contextual / Inline Errors**:
  - Use [`AppErrorBanner`](client/lib/core/widgets/app_error_banner.dart) (`client/lib/core/widgets/app_error_banner.dart`) for non-blocking errors, warning notices, or inline form feedback.
- **Toasts & Feedback**:
  - Use [`showAppSnackBar()`](client/lib/core/widgets/app_snackbar.dart), [`showAppErrorSnackBar()`](client/lib/core/widgets/app_snackbar.dart), or [`showAppSuccessSnackBar()`](client/lib/core/widgets/app_snackbar.dart) (`client/lib/core/widgets/app_snackbar.dart`) instead of directly invoking `ScaffoldMessenger.of(context).showSnackBar()`.

---

## 4. Common Core UI Widgets

Always check [`client/lib/core/widgets/`](client/lib/core/widgets/) before writing common UI elements:
- **Buttons**: [`AppButton`](client/lib/core/widgets/app_button.dart) (`AppButton.primary`, `AppButton.secondary`, `AppButton.outlined`, `AppButton.destructive`, `AppButton.ghost`) to guarantee touch target heights and state styling.
- **Text Inputs**: [`AppTextField`](client/lib/core/widgets/app_text_field.dart) for standard borders, focus rings, prefixes/suffixes, and validation.
- **Date Inputs**: [`AppDateField`](client/lib/core/widgets/app_date_field.dart) for unified date selection.
- **Avatars**: [`AppAvatar`](client/lib/core/widgets/app_avatar.dart) for user/workspace initials and images.
- **Empty States**: [`AppEmptyState`](client/lib/core/widgets/app_empty_state.dart) for zero-data views (icons, title, subtitle, CTA button).
- **Badges**: [`StatusBadge`](client/lib/core/widgets/status_badge.dart) and [`RealtimeStatusBadge`](client/lib/core/widgets/realtime_status_badge.dart).
- **Destructive Sections**: [`AppDangerZone`](client/lib/core/widgets/app_danger_zone.dart) for irreversible actions in settings or management screens.

---

## 5. Refactoring & Code Modification Checklist

When refactoring, fixing bugs, or implementing new screens:
1. **Audit Imports**: Replace duplicate ad-hoc widgets with imports from `package:client/core/...`.
2. **Standardize Cubit Inheritance**: If an existing Cubit does async work, refactor it to extend `SafeActionCubit` and wrap calls with `safeExecute`.
3. **Replace Custom Bottom Sheets**: Ensure modals use `showAppBottomSheet` with `AppSheetDragHandle` and `AppSheetHeader`.
4. **Standardize Confirmations**: Replace ad-hoc `showDialog(builder: (_) => AlertDialog(...))` with `showAppConfirmDialog`.
5. **Standardize Error Views**: Ensure all failure states in BlocBuilder / BlocConsumer render `AppErrorState` or `AppErrorBanner`.

