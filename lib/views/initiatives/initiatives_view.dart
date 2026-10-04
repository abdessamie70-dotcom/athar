import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/athar_provider.dart';
import '../../models/action_log_model.dart';
import '../../models/initiative_model.dart';
import '../../theme/app_theme.dart';
import '../action_logging/log_action_sheet.dart';

class InitiativesView extends StatefulWidget {
  const InitiativesView({super.key});

  @override
  State<InitiativesView> createState() => _InitiativesViewState();
}

class _InitiativesViewState extends State<InitiativesView> {
  String? _selectedCategory;
  EstimatedCost? _selectedCost;

  ActionCategory _mapCategory(String cat) {
    switch (cat) {
      case 'knowledge':
        return ActionCategory.continuousKnowledge;
      case 'sadaqah':
        return ActionCategory.ongoingCharity;
      case 'service':
      default:
        return ActionCategory.goodDeed;
    }
  }

  void _applyFilter() {
    context.read<AtharProvider>().filterInitiatives(
      category: _selectedCategory,
      maxCost: _selectedCost,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AtharProvider>(
      builder: (context, provider, _) {
        final initiatives = provider.initiatives;

        return Scaffold(
          appBar: AppBar(
            title: const Text('بذور الأثر والمبادرات'),
          ),
          body: Column(
            children: [
              // Filter Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: isDark ? AppTheme.darkSurface : const Color(0xFFF7F4EE),
                child: Column(
                  children: [
                    // Category Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('الكل'),
                            selected: _selectedCategory == null,
                            onSelected: (_) {
                              setState(() => _selectedCategory = null);
                              _applyFilter();
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('علم نافع'),
                            selected: _selectedCategory == 'knowledge',
                            onSelected: (_) {
                              setState(() => _selectedCategory = 'knowledge');
                              _applyFilter();
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('صدقة جارية'),
                            selected: _selectedCategory == 'sadaqah',
                            onSelected: (_) {
                              setState(() => _selectedCategory = 'sadaqah');
                              _applyFilter();
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('خدمة مجتمعية'),
                            selected: _selectedCategory == 'service',
                            onSelected: (_) {
                              setState(() => _selectedCategory = 'service');
                              _applyFilter();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Cost Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            'التكلفة: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                            ),
                          ),
                          ChoiceChip(
                            label: const Text('جميع التكاليف'),
                            selected: _selectedCost == null,
                            onSelected: (_) {
                              setState(() => _selectedCost = null);
                              _applyFilter();
                            },
                          ),
                          const SizedBox(width: 6),
                          ChoiceChip(
                            label: const Text('بدون تكلفة (وقت وجهد)'),
                            selected: _selectedCost == EstimatedCost.zeroCost,
                            onSelected: (_) {
                              setState(() => _selectedCost = EstimatedCost.zeroCost);
                              _applyFilter();
                            },
                          ),
                          const SizedBox(width: 6),
                          ChoiceChip(
                            label: const Text('تكلفة يسيرة'),
                            selected: _selectedCost == EstimatedCost.lowCost,
                            onSelected: (_) {
                              setState(() => _selectedCost = EstimatedCost.lowCost);
                              _applyFilter();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Initiatives List
              Expanded(
                child: initiatives.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد مبادرات مطابقة للفلتر المحدد',
                          style: TextStyle(
                            color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: initiatives.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = initiatives[index];

                          return Container(
                            padding: const EdgeInsets.all(16),
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primarySlateGreen.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item.categoryArabicLabel,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppTheme.primarySlateGreenLight : AppTheme.primarySlateGreen,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF2F3933) : const Color(0xFFF3ECE0),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item.estimatedCost.label,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? AppTheme.accentGoldLight : AppTheme.accentGoldDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Wrap(
                                      spacing: 6,
                                      children: item.tags.map((tag) {
                                        return Text(
                                          '#$tag',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        LogActionSheet.show(
                                          context,
                                          initialTitle: item.title,
                                          initialCategory: _mapCategory(item.category),
                                        );
                                      },
                                      icon: const Icon(Icons.flash_on_rounded, size: 16),
                                      label: const Text('تبنَّ المبادرة الآن'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
