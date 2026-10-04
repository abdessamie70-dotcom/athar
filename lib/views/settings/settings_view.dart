import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/athar_provider.dart';
import '../../theme/app_theme.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late int _targetMinutes;

  @override
  void initState() {
    super.initState();
    _targetMinutes = context.read<AtharProvider>().user.dailyTargetMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AtharProvider>(
      builder: (context, provider, _) {
        final user = provider.user;

        return Scaffold(
          appBar: AppBar(
            title: const Text('الإعدادات والسكينة'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF28362E) : const Color(0xFFE8E4DA),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.primarySlateGreen.withOpacity(0.15),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0] : 'أ',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primarySlateGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.textLight : AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Daily Target Setting
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                        Text(
                          'الهدف اليومي للأثر الباقي',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.textLight : AppTheme.textDark,
                          ),
                        ),
                        Text(
                          '$_targetMinutes دقيقة',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'الحد الأدنى المرجو يومياً في عمل صالح أو علم نافع أو صدقة جارية.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _targetMinutes.toDouble(),
                      min: 10,
                      max: 180,
                      divisions: 17,
                      activeColor: AppTheme.primarySlateGreen,
                      onChanged: (val) {
                        setState(() => _targetMinutes = val.toInt());
                      },
                      onChangeEnd: (val) {
                        provider.updateDailyTarget(val.toInt());
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Theme Switcher
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF28362E) : const Color(0xFFE8E4DA),
                  ),
                ),
                child: SwitchListTile(
                  title: Text(
                    'الوضع الداكن الهادئ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.textLight : AppTheme.textDark,
                    ),
                  ),
                  subtitle: Text(
                    'تقليل إجهاد العين أثناء الليل للمحافظة على السكينة',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                    ),
                  ),
                  value: user.preferences.darkMode,
                  activeColor: AppTheme.accentGoldLight,
                  onChanged: (val) => provider.toggleDarkMode(val),
                ),
              ),
              const SizedBox(height: 24),

              // App Philosophy & Vision
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2822) : const Color(0xFFF3ECE0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'عن تطبيق أثر (أثر باقٍ)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primarySlateGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'تطبيق إنتاجية واعية مصمم لإعادة توجيه بوصلة يومك من الاستهلاك العابر إلى الأثر الصالح المستمر.\n\n"إذا مات الإنسان انقطع عنه عمله إلا من ثلاثة: صدقة جارية، أو علم ينتفع به، أو ولد صالح يدعو له".',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.6,
                        color: isDark ? AppTheme.textLight : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
