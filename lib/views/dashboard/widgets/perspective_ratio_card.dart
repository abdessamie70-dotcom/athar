import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class PerspectiveRatioCard extends StatelessWidget {
  final double lastingRatio;
  final int lastingMinutes;
  final int transientMinutes;
  final VoidCallback onLogTransientTap;

  const PerspectiveRatioCard({
    super.key,
    required this.lastingRatio,
    required this.lastingMinutes,
    required this.transientMinutes,
    required this.onLogTransientTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalMinutes = lastingMinutes + transientMinutes;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF28362E) : const Color(0xFFE8E4DA),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.balance_rounded,
                    size: 20,
                    color: isDark ? AppTheme.accentGoldLight : AppTheme.accentGold,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ميزان الاستثمار: الباقي مقابل العابر',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.textLight : AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onLogTransientTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2E3832) : const Color(0xFFF0EBE1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        size: 14,
                        color: isDark ? AppTheme.textLight : AppTheme.textDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'قيد وقت عابر',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textLight : AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Ratio Display
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${lastingRatio.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppTheme.accentGoldLight : AppTheme.primarySlateGreen,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'من وقتك اليوم موجه للأثر الدائم',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Split Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: totalMinutes == 0
                  ? Container(color: isDark ? Colors.grey[800] : const Color(0xFFE2DDD2))
                  : Row(
                      children: [
                        Expanded(
                          flex: lastingMinutes,
                          child: Container(
                            color: AppTheme.primarySlateGreen,
                          ),
                        ),
                        if (transientMinutes > 0)
                          Expanded(
                            flex: transientMinutes,
                            child: Container(
                              color: isDark ? const Color(0xFF5A4D41) : const Color(0xFFD6A284),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          // Legends
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppTheme.primarySlateGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'أثر باقٍ: $lastingMinutes د',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF5A4D41) : const Color(0xFFD6A284),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'استهلاك عابر: $transientMinutes د',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
