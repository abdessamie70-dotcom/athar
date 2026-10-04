import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/athar_provider.dart';
import '../../theme/app_theme.dart';

class PerspectiveView extends StatefulWidget {
  const PerspectiveView({super.key});

  @override
  State<PerspectiveView> createState() => _PerspectiveViewState();
}

class _PerspectiveViewState extends State<PerspectiveView> {
  final TextEditingController _transientController = TextEditingController();

  @override
  void dispose() {
    _transientController.dispose();
    super.dispose();
  }

  void _showAddTransientSheet(BuildContext context) {
    _transientController.text = '30';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'تسجيل وقت استهلاك عابر',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textLight : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'الوقت المستهلك في شبكات التواصل، الألعاب، أو الترفيه المجرد. يساعدك هذا التسجيل في معرفة أين يضيع العمر.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [15, 30, 60, 120].map((mins) {
                  return ActionChip(
                    label: Text('$mins دقيقة'),
                    onPressed: () => _transientController.text = '$mins',
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _transientController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'المدة بالدقائق',
                  suffixText: 'دقيقة',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final mins = int.tryParse(_transientController.text.trim()) ?? 0;
                  if (mins > 0) {
                    context.read<AtharProvider>().logTransientTime(mins);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('إضافة إلى ميزان اليوم'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AtharProvider>(
      builder: (context, provider, _) {
        final metric = provider.todayMetric;
        final lasting = metric.lastingTimeMinutes;
        final transient = metric.transientTimeMinutes;
        final total = lasting + transient;
        final ratio = metric.lastingRatio;

        return Scaffold(
          appBar: AppBar(
            title: const Text('ميزان الوقت والبصيرة'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Concept Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? const Color(0xFF28362E) : const Color(0xFFE8E4DA),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: isDark ? AppTheme.accentGoldLight : AppTheme.accentGold,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'معادلة الاستثمار الأبدي',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.textLight : AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF232D28) : const Color(0xFFF7F4EE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'النسبة = (الوقت الباقي ÷ إجمالي الوقت المسجل) × 100',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Pie / Donut Chart using fl_chart
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF28362E) : const Color(0xFFE8E4DA),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'توزيع ساعات اليوم',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.textLight : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 190,
                      child: total == 0
                          ? Center(
                              child: Text(
                                'لم يتم قيد أي وقت اليوم بعد',
                                style: TextStyle(
                                  color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                                ),
                              ),
                            )
                          : PieChart(
                              PieChartData(
                                sectionsSpace: 4,
                                centerSpaceRadius: 55,
                                sections: [
                                  if (lasting > 0)
                                    PieChartSectionData(
                                      color: AppTheme.primarySlateGreen,
                                      value: lasting.toDouble(),
                                      title: '${ratio.toStringAsFixed(0)}%',
                                      radius: 40,
                                      titleStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  if (transient > 0)
                                    PieChartSectionData(
                                      color: isDark ? const Color(0xFF6B5848) : const Color(0xFFC78263),
                                      value: transient.toDouble(),
                                      title: '${(100 - ratio).toStringAsFixed(0)}%',
                                      radius: 40,
                                      titleStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildLegendItem(
                          context,
                          color: AppTheme.primarySlateGreen,
                          label: 'الأثر الباقي',
                          value: '$lasting دقيقة',
                        ),
                        _buildLegendItem(
                          context,
                          color: isDark ? const Color(0xFF6B5848) : const Color(0xFFC78263),
                          label: 'الاستهلاك العابر',
                          value: '$transient دقيقة',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Action Buttons
              ElevatedButton.icon(
                onPressed: () => _showAddTransientSheet(context),
                icon: const Icon(Icons.timer_outlined),
                label: const Text('قيد وقت عابر (تصفح / ترفيه)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF38473E) : const Color(0xFF60564D),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(BuildContext context, {
    required Color color,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.textLight : AppTheme.textDark,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
