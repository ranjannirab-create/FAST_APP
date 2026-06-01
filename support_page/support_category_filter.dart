import 'package:flutter/material.dart';

class SupportCategory {
  static const all = "all";
  static const depression = "depression";
  static const anxiety = "anxiety";
  static const family = "family";
  static const relationship = "relationship";
  static const study = "study";
  static const loneliness = "loneliness";

  static const values = [
    all,
    depression,
    anxiety,
    family,
    relationship,
    study,
    loneliness,
  ];
}

class SupportCategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const SupportCategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  IconData _getIcon(String category) {
    switch (category) {
      case SupportCategory.depression:
        return Icons.sentiment_very_dissatisfied_rounded;

      case SupportCategory.anxiety:
        return Icons.sick_rounded;

      case SupportCategory.family:
        return Icons.family_restroom_rounded;

      case SupportCategory.relationship:
        return Icons.favorite_rounded;

      case SupportCategory.study:
        return Icons.menu_book_rounded;

      case SupportCategory.loneliness:
        return Icons.person_off_rounded;

      default:
        return Icons.grid_view_rounded;
    }
  }

  String _getLabel(String category) {
    switch (category) {
      case SupportCategory.all:
        return "সব";

      case SupportCategory.depression:
        return "ডিপ্রেশন";

      case SupportCategory.anxiety:
        return "উদ্বেগ";

      case SupportCategory.family:
        return "পরিবার";

      case SupportCategory.relationship:
        return "সম্পর্ক";

      case SupportCategory.study:
        return "পড়াশোনা";

      case SupportCategory.loneliness:
        return "একাকীত্ব";

      default:
        return category;
    }
  }

  Color _getColor(String category, bool isSelected) {
    if (!isSelected) return Colors.grey;

    switch (category) {
      case SupportCategory.depression:
        return Colors.blueGrey;

      case SupportCategory.anxiety:
        return Colors.orange;

      case SupportCategory.family:
        return Colors.green;

      case SupportCategory.relationship:
        return Colors.pink;

      case SupportCategory.study:
        return Colors.blue;

      case SupportCategory.loneliness:
        return Colors.deepPurple;

      default:
        return const Color(0xFF2FA089);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 85,

      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: SupportCategory.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),

        itemBuilder: (context, index) {
          final category = SupportCategory.values[index];
          final isSelected = selectedCategory == category;

          return GestureDetector(
            onTap: () => onCategoryChanged(category),

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),

              width: 72,

              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 7,
              ),

              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFF1FBF4)
                    : Colors.white,

                borderRadius: BorderRadius.circular(16),

                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFB7E4C7)
                      : const Color(0xFFE2F1E7),
                  width: 0.9,
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  Container(
                    height: 32,
                    width: 32,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? _getColor(category, true).withOpacity(0.12)
                          : const Color(0xFFF6FCF8),
                    ),

                    child: Icon(
                      _getIcon(category),
                      size: 18,
                      color: _getColor(category, isSelected),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    _getLabel(category),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize: 10.2,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF2FA089)
                          : Colors.grey.shade700,
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