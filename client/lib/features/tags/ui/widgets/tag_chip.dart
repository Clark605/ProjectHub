import 'package:flutter/material.dart';

import 'package:client/features/tags/data/models/tag_dto.dart';

class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.tag,
    this.onDeleted,
    this.onTap,
    this.isSelected = false,
  });

  final TagDto tag;
  final VoidCallback? onDeleted;
  final VoidCallback? onTap;
  final bool isSelected;

  static Color parseHexColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return const Color(0xFF0D9488);
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = parseHexColor(tag.color);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: EdgeInsets.only(
          left: 8,
          right: onDeleted != null ? 4 : 8,
          top: 2,
          bottom: 2,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? baseColor.withValues(alpha: 0.35)
              : baseColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? baseColor : baseColor.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: baseColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              tag.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: baseColor,
              ),
            ),
            if (onDeleted != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDeleted,
                child: Icon(Icons.close_rounded, size: 14, color: baseColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
