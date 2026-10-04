import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/athar_provider.dart';
import '../../services/voice_input_service.dart';
import '../../theme/app_theme.dart';
import '../action_logging/log_action_sheet.dart';
import '../action_logging/voice_action_sheet.dart';
import 'widgets/perspective_ratio_card.dart';
import 'widgets/progress_ring_card.dart';
import 'widgets/recent_actions_list.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final VoiceInputService _voiceService = VoiceInputService();

  void _showLogTransientDialog(BuildContext context) {
    final controller = TextEditingController(text: '30');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        title: Text(
          'قيد وقت عابر (استهلاك / ترفيه)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.textLight : AppTheme.textDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تسجيل الوقت المستغرق في التصفح أو الترفيه يمنحك بصيرة ووعياً بحقيقة استثمار ساعاتك.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'المدة بالدقائق',
                suffixText: 'دقيقة',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final minutes = int.tryParse(controller.text.trim()) ?? 0;
              if (minutes > 0) {
                context.read<AtharProvider>().logTransientTime(minutes);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تسجيل الوقت العابر وتحديث ميزان الاستثمار'),
                  ),
                );
              }
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AtharProvider>(
      builder: (context, provider, _) {
        final metric = provider.todayMetric;
        final user = provider.user;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                Text(
                  'أثر باقٍ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: isDark ? AppTheme.accentGoldLight : AppTheme.primarySlateGreen,
                  ),
                ),
                Text(
                  'وَالْآخِرَةُ خَيْرٌ وَأَبْقَىٰ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.mic_rounded),
                tooltip: 'تسجيل صوتي سريع',
                onPressed: () => VoiceActionSheet.show(context, _voiceService),
              ),
            ],
          ),
          floatingActionButton: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Voice-to-Action Floating Button
              FloatingActionButton.extended(
                heroTag: 'voice_action_fab',
                onPressed: () => VoiceActionSheet.show(context, _voiceService),
                backgroundColor: AppTheme.accentGold,
                foregroundColor: Colors.white,
                elevation: 4,
                icon: const Icon(Icons.mic_rounded),
                label: const Text(
                  'تسجيل صوتي',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              // Manual Log Button
              FloatingActionButton(
                heroTag: 'manual_action_fab',
                onPressed: () => LogActionSheet.show(context),
                backgroundColor: AppTheme.primarySlateGreen,
                foregroundColor: Colors.white,
                elevation: 4,
                tooltip: 'تدوين يدوي',
                child: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => provider.initialize(),
            color: AppTheme.primarySlateGreen,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              children: [
                // 1. Progress Ring Card
                ProgressRingCard(
                  lastingMinutes: metric.lastingTimeMinutes,
                  targetMinutes: user.dailyTargetMinutes,
                  completedTarget: metric.completedTarget,
                ),
                const SizedBox(height: 16),

                // 2. Perspective & Time Awareness Metric Card
                PerspectiveRatioCard(
                  lastingRatio: metric.lastingRatio,
                  lastingMinutes: metric.lastingTimeMinutes,
                  transientMinutes: metric.transientTimeMinutes,
                  onLogTransientTap: () => _showLogTransientDialog(context),
                ),
                const SizedBox(height: 24),

                // 3. Header for Recent Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'صحيفة أثرك اليوم',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.textLight : AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '${provider.recentActions.length} أعمال مدونة',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 4. Actions List
                RecentActionsList(
                  actions: provider.recentActions,
                  onDelete: (id) => provider.deleteAction(id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
