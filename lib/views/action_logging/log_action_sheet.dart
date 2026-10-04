import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/athar_provider.dart';
import '../../models/action_log_model.dart';
import '../../theme/app_theme.dart';

class LogActionSheet extends StatefulWidget {
  final String? initialTitle;
  final ActionCategory? initialCategory;

  const LogActionSheet({
    super.key,
    this.initialTitle,
    this.initialCategory,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialTitle,
    ActionCategory? initialCategory,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LogActionSheet(
        initialTitle: initialTitle,
        initialCategory: initialCategory,
      ),
    );
  }

  @override
  State<LogActionSheet> createState() => _LogActionSheetState();
}

class _LogActionSheetState extends State<LogActionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _customDurationController = TextEditingController();

  late ActionCategory _selectedCategory;
  int _selectedDuration = 30;
  bool _isCustomDuration = false;
  bool _isPrivate = false;
  bool _isSubmitting = false;

  final List<int> _presetDurations = [15, 30, 45, 60];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _selectedCategory = widget.initialCategory ?? ActionCategory.goodDeed;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _customDurationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final duration = _isCustomDuration
        ? int.tryParse(_customDurationController.text.trim()) ?? 0
        : _selectedDuration;

    if (duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تحديد مدة أكبر من صفر دقيقة')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final provider = context.read<AtharProvider>();
    final success = await provider.logAction(
      title: _titleController.text.trim(),
      category: _selectedCategory,
      durationMinutes: duration,
      notes: _notesController.text.trim(),
      isPrivate: _isPrivate,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تقبل الله عملك وأثره في ميزان حسناتك ✨'),
            backgroundColor: AppTheme.primarySlateGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'حدث خطأ أثناء حفظ العمل'),
            backgroundColor: Colors.brown,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle Bar
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تدوين أثر صالح جديد',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.textLight : AppTheme.textDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Category Choice Chips
              Text(
                'نوع الأثر:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ActionCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? AppTheme.textLight : AppTheme.textDark),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppTheme.primarySlateGreen,
                        backgroundColor: isDark ? const Color(0xFF2B3630) : const Color(0xFFF3EFE7),
                        showCheckmark: false,
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategory = cat);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Title Input
              TextFormField(
                controller: _titleController,
                autofocus: widget.initialTitle == null,
                decoration: const InputDecoration(
                  labelText: 'ماذا بذلت لوجه الله؟',
                  hintText: 'مثال: مدارسة علم، صدقة ماء، صلة رحم...',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'يرجى كتابة عنوان للعمل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Duration Presets
              Text(
                'المدة المستغرقة (دقائق):',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ..._presetDurations.map((duration) {
                    final isSelected = !_isCustomDuration && _selectedDuration == duration;
                    return ChoiceChip(
                      label: Text('$duration د'),
                      selected: isSelected,
                      selectedColor: isDark ? AppTheme.accentGold : AppTheme.primarySlateGreen,
                      onSelected: (val) {
                        setState(() {
                          _isCustomDuration = false;
                          _selectedDuration = duration;
                        });
                      },
                    );
                  }),
                  ChoiceChip(
                    label: const Text('مدة أخرى'),
                    selected: _isCustomDuration,
                    selectedColor: isDark ? AppTheme.accentGold : AppTheme.primarySlateGreen,
                    onSelected: (val) {
                      setState(() => _isCustomDuration = true);
                    },
                  ),
                ],
              ),
              if (_isCustomDuration) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _customDurationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'أدخل المدة بالدقائق',
                    hintText: 'مثال: 90',
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات أو خواطر خاصة (اختياري)',
                ),
              ),
              const SizedBox(height: 12),
              // Private Checkbox
              CheckboxListTile(
                value: _isPrivate,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppTheme.primarySlateGreen,
                title: Text(
                  'أثر خاص بيني وبين الله فقط (سريرة)',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                  ),
                ),
                onChanged: (val) => setState(() => _isPrivate = val ?? false),
              ),
              const SizedBox(height: 16),
              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('تسجيل في صحيفة الأثر'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
