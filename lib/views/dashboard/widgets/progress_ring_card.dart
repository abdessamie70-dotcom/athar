import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ProgressRingCard extends StatelessWidget {
  final int lastingMinutes;
  final int targetMinutes;
  final bool completedTarget;

  const ProgressRingCard({
    super.key,
    required this.lastingMinutes,
    required this.targetMinutes,
    required this.completedTarget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = targetMinutes > 0 ? (lastingMinutes / targetMinutes).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF28362E) : const Color(0xFFE8E4DA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress Indicator
          SizedBox(
            width: 84,
            height: 84,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: isDark
                      ? const Color(0xFF232D28)
                      : const Color(0xFFEAE6DC),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completedTarget ? AppTheme.accentGold : AppTheme.primarySlateGreen,
                  ),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.textLight : AppTheme.textDark,
                        ),
                      ),
                      Text(
                        'الإنجاز',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Info Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: completedTarget
                            ? AppTheme.accentGold.withOpacity(0.18)
                            : AppTheme.primarySlateGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        completedTarget ? 'اكتمل هدف اليوم ★' : 'الأثر اليومي المرجو',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: completedTarget
                              ? (isDark ? AppTheme.accentGoldLight : AppTheme.accentGoldDark)
                              : (isDark ? AppTheme.primarySlateGreenLight : AppTheme.primarySlateGreen),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: theme.textTheme.bodyMedium?.fontFamily,
                      color: isDark ? AppTheme.textLight : AppTheme.textDark,
                    ),
                    children: [
                      TextSpan(
                        text: '$lastingMinutes ',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '/ $targetMinutes دقيقة',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  completedTarget
                      ? 'ما زاد فهو رفعة وبركة في صحيفة عملك'
                      : 'متبقي ${targetMinutes > lastingMinutes ? targetMinutes - lastingMinutes : 0} دقيقة لبلوغ غايتك اليوم',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
