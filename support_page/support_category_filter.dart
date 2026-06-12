import 'package:flutter/material.dart';
import '../support_page/support_categories.dart';

class SupportCategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const SupportCategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  IconData _getIconForCategory(String category) {
    switch (category) {
      case SupportCategory.mental:
        return Icons.psychology_rounded;

      case SupportCategory.family:
        return Icons.family_restroom_rounded;

      case SupportCategory.relationship:
        return Icons.favorite_outline_rounded;

      case SupportCategory.study:
        return Icons.menu_book_rounded;

      case SupportCategory.loneliness:
        return Icons.person_outline_rounded;

      case SupportCategory.other:
        return Icons.more_horiz_rounded;

      default:
        return Icons.volunteer_activism_rounded;
    }
  }

  Color _getIconColor(String category) {
    switch (category) {
      case SupportCategory.mental:
        return const Color(0xFF6C63FF);

      case SupportCategory.family:
        return const Color(0xFF4A90E2);

      case SupportCategory.relationship:
        return Colors.pinkAccent;

      case SupportCategory.study:
        return const Color(0xFF00A896);

      case SupportCategory.loneliness:
        return Colors.orangeAccent;

      default:
        return const Color(0xFF5B6CF0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: SupportCategory.values.length,
        // ✅ ঠিক করা: ডুপ্লিকেট আন্ডারস্কোর পরিবর্তন
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = SupportCategory.values[index];
          final isSelected = selectedCategory == category;

          return GestureDetector(
            onTap: () => onCategoryChanged(category),

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),

              width: 68,

              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 7,
              ),

              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFF4F5FF)
                    : Colors.white,

                borderRadius: BorderRadius.circular(16),

                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFD9DEFF)
                      : const Color(0xFFE9EBFF),
                  width: 0.9,
                ),

                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B6CF0)
                        .withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Container(
                    height: 31,
                    width: 31,

                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F8FF),
                      shape: BoxShape.circle,
                    ),

                    child: Icon(
                      _getIconForCategory(category),
                      size: 18,
                      color: _getIconColor(category),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    category,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize: 10.2,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}