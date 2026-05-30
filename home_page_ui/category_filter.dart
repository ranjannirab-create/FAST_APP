import 'package:flutter/material.dart';
import '../home_page/post_categories.dart';

class CategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  IconData _getIconForCategory(String category) {
    switch (category) {
      case PostCategory.lifestyle:
        return Icons.eco_rounded;

      case PostCategory.study:
        return Icons.menu_book_rounded;

      case PostCategory.goal:
        return Icons.track_changes_rounded;

      case PostCategory.feeling:
        return Icons.favorite_rounded;

      case PostCategory.relationship:
        return Icons.people_alt_rounded;

      case PostCategory.other:
        return Icons.more_horiz_rounded;

      default:
        return Icons.category_rounded;
    }
  }

  Color _getIconColor(String category) {
    switch (category) {
      case PostCategory.feeling:
        return Colors.redAccent;

      default:
        return const Color(0xFF228B5A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: PostCategory.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = PostCategory.values[index];
          final isSelected = selectedCategory == category;

          return GestureDetector(
            onTap: () => onCategoryChanged(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),

              // ✅ compact width
              width: 64,

              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 7,
              ),

              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFF1FBF4)
                    : Colors.white,

                borderRadius: BorderRadius.circular(16),

                // ✅ thin elegant border
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFB7E4C7)
                      : const Color(0xFFE2F1E7),
                  width: 0.9,
                ),

                // ✅ soft premium shadow
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.025),
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
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6FCF8),
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