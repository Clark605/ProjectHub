# Mobile-First Priority Rule

1. **Mobile Experience Takes Precedence**: In all UI implementations, layouts, dialogs, and navigation flows, prioritize the **Mobile (< 768px)** experience first before Desktop and Tablet.
2. **Ergonomic Standards**:
   - Touch targets must be at least 48-52px height (buttons, inputs).
   - Use Bottom Sheets (`showModalBottomSheet`) for selections and pickers on mobile instead of small desktop dropdown popovers.
   - Respect mobile safe areas, thumb reach zones, and keyboard resizing (`SingleChildScrollView`).
   - Page margins on mobile must be 16px with comfortable touch padding.
3. **Verification**: Always verify mobile layout rendering and run widget tests on mobile viewports (< 768px).

