# Responsive Kanban Navigation and Modal Interactions

On mobile viewports (< 768px), the Kanban board uses a swipeable `PageView` paired with a segmented column tab bar rather than a free-form horizontally scrolling canvas. Task creation and editing use a draggable modal bottom sheet on mobile and a centered modal dialog on desktop/tablet. Task cards support 1-tap quick actions on assignee avatars and status pills alongside full-sheet editing to take advantage of lightweight dedicated PATCH endpoints. We chose this design to eliminate vertical/horizontal gesture contention on mobile touch screens and provide fluid, thumb-accessible task orchestration.

