import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/action_log_model.dart';
import '../../../theme/app_theme.dart';

class RecentActionsList extends StatelessWidget {
  final List<ActionLogModel> actions;
  final Function(String) onDelete;

  const RecentActionsList({
    super.key,
    required this.actions,
    required this.onDelete,
  });

  Color _getCategoryColor(ActionCategory cat) {
    switch (cat) {
      case ActionCategory.continuousKnowledge:
        return AppTheme.categoryKnowledge;
      case ActionCategory.ongoingCharity:
        return AppTheme.categoryCharity;
      case ActionCategory.goodDeed:
        return AppTheme.categoryGoodDeed;
    }
  }

  IconData _getCategoryIcon(ActionCategory cat) {
    switch (cat) {
      case ActionCategory.continuousKnowledge:
        return Icons.menu_book_rounded;
      case ActionCategory.ongoingCharity:
        return Icons.volunteer_activism_rounded;
      case ActionCategory.goodDeed:
        return Icons.favorite_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (actions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF28362E) : const Color(0xFFE8E4DA),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.spa_outlined,
              size: 44,
              color: isDark ? AppTheme.accentGoldLight.withOpacity(0.5) : AppTheme.primarySlateGreen.withOpacity(0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'لم تُسجل أثراً بعد اليوم',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textLight : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'كل معروف صدقة.. اضغط زر الإضافة لتدوين أثرك الصالح',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final action = actions[index];
        final catColor = _getCategoryColor(action.category);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF28362E) : const Color(0xFFE8E4DA),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Icon badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(action.category),
                  color: catColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            action.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.textLight : AppTheme.textDark,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2B3730) : const Color(0xFFF1EDE4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${action.durationMinutes} دقيقة',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppTheme.accentGoldLight : AppTheme.primarySlateGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          action.category.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: catColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('hh:mm a').format(action.dateLogged),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                          ),
                        ),
                        if (action.isPrivate) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 14,
                            color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                          ),
                        ],
                      ],
                    ),
                    if (action.notes != null && action.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        action.notes!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Delete Button
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                onPressed: () => onDelete(action.actionId),
                tooltip: 'حذف',
              ),
            ],
          ),
        );
      },
    );
  }
}
