import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/athar_provider.dart';
import '../../models/action_log_model.dart';
import '../../services/smart_voice_parser_service.dart';
import '../../services/voice_input_service.dart';
import '../../theme/app_theme.dart';
import 'log_action_sheet.dart';
import 'widgets/voice_permission_dialog.dart';

class VoiceActionSheet extends StatefulWidget {
  final VoiceInputService voiceService;

  const VoiceActionSheet({
    super.key,
    required this.voiceService,
  });

  static Future<void> show(BuildContext context, VoiceInputService voiceService) async {
    // 1. Check microphone permission first
    final permissionState = await voiceService.checkAndRequestMicrophonePermission();

    if (context.mounted) {
      if (permissionState == VoicePermissionState.permanentlyDenied ||
          permissionState == VoicePermissionState.denied) {
        // Direct gentle dialog with Phone Settings button
        await VoicePermissionDialog.show(context, voiceService);
        return;
      }

      if (permissionState == VoicePermissionState.granted) {
        // Permission granted -> Open voice listening sheet immediately
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => VoiceActionSheet(voiceService: voiceService),
        );
      }
    }
  }

  @override
  State<VoiceActionSheet> createState() => _VoiceActionSheetState();
}

class _VoiceActionSheetState extends State<VoiceActionSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final TextEditingController _titleController;

  String _spokenWords = '';
  ParsedVoiceAction? _parsedAction;
  bool _isListening = false;
  bool _isSaving = false;
  String? _statusMessage;

  // Editable parsed values
  int _selectedDuration = 30;
  ActionCategory _selectedCategory = ActionCategory.goodDeed;

  final List<int> _durationPresets = [15, 20, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startListening();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pulseController.dispose();
    widget.voiceService.stopListening();
    super.dispose();
  }

  void _updateParsedState(ParsedVoiceAction parsed) {
    _parsedAction = parsed;
    _selectedDuration = parsed.durationMinutes;
    _selectedCategory = parsed.category;
    _titleController.text = parsed.title;
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
      _statusMessage = 'استمع لصوتك.. تحدث بحرية (مثال: شرح درس لزميلي نصف ساعة)';
    });

    try {
      await widget.voiceService.startListening(
        onResult: (text) {
          if (!mounted) return;
          setState(() {
            _spokenWords = text;
            if (text.isNotEmpty) {
              final parsed = SmartVoiceParserService.parse(text);
              _updateParsedState(parsed);
              _statusMessage = 'تم التعرف والاستخلاص الذكي بنجاح';
            }
          });
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isListening = false;
          _statusMessage = 'تعذر تشغيل الصوت: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _stopListening() async {
    await widget.voiceService.stopListening();
    if (mounted) {
      setState(() {
        _isListening = false;
        if (_spokenWords.isNotEmpty) {
          final parsed = SmartVoiceParserService.parse(_spokenWords);
          _updateParsedState(parsed);
        }
      });
    }
  }

  Future<void> _confirmAndSave() async {
    final titleToSave = _titleController.text.trim();
    if (titleToSave.isEmpty) return;

    setState(() => _isSaving = true);
    final provider = context.read<AtharProvider>();

    final success = await provider.logAction(
      title: titleToSave,
      category: _selectedCategory,
      durationMinutes: _selectedDuration,
      notes: _spokenWords.isNotEmpty && _spokenWords != titleToSave
          ? 'مسجل صوتياً: "$_spokenWords"'
          : null,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('تقبل الله عملك: "$titleToSave" ($_selectedDuration دقيقة) ✨'),
                ),
              ],
            ),
            backgroundColor: AppTheme.primarySlateGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'حدث خطأ أثناء الحفظ'),
            backgroundColor: Colors.brown,
          ),
        );
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasParsedResult = _parsedAction != null && _spokenWords.isNotEmpty;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
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
                Row(
                  children: [
                    const Icon(Icons.mic_rounded, color: AppTheme.primarySlateGreen, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'الاستخلاص الذكي من الصوت (Smart Voice)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.textLight : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Status & Helper Message
            Text(
              _statusMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
              ),
            ),
            const SizedBox(height: 16),

            // Animated Pulsing Mic Button
            Center(
              child: GestureDetector(
                onTap: () {
                  if (_isListening) {
                    _stopListening();
                  } else {
                    _startListening();
                  }
                },
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    final scale = _isListening ? _pulseAnimation.value : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isListening
                              ? AppTheme.primarySlateGreen
                              : (isDark ? const Color(0xFF2C3931) : const Color(0xFFEBE6DC)),
                          boxShadow: _isListening
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primarySlateGreen.withOpacity(0.35),
                                    blurRadius: 20,
                                    spreadRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                          color: _isListening
                              ? Colors.white
                              : (isDark ? AppTheme.accentGoldLight : AppTheme.primarySlateGreen),
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _isListening ? 'اضغط لإيقاف الاستماع والتحليل' : 'اضغط للبدء بالتحدث',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Spoken Text Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF232D28) : const Color(0xFFF7F4EE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF2F3C34) : const Color(0xFFE8E3D7),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'النص المنطوق:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                        ),
                      ),
                      if (_isListening)
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'جاري الاستماع',
                              style: TextStyle(fontSize: 10, color: Colors.red),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _spokenWords.isEmpty ? 'في انتظار صوتك الكريم...' : _spokenWords,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      fontStyle: _spokenWords.isEmpty ? FontStyle.italic : FontStyle.normal,
                      color: _spokenWords.isEmpty
                          ? (isDark ? Colors.grey[500] : Colors.grey[400])
                          : (isDark ? AppTheme.textLight : AppTheme.textDark),
                    ),
                  ),
                ],
              ),
            ),

            // Smart Parsed Review Card
            if (hasParsedResult) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B241F) : const Color(0xFFFBF8F2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppTheme.accentGold.withOpacity(0.5),
                    width: 1.5,
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
                            const Icon(Icons.auto_awesome, color: AppTheme.accentGold, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'بيانات الأثر المستخلصة ذكياً:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.accentGoldLight : AppTheme.accentGoldDark,
                              ),
                            ),
                          ],
                        ),
                        if (_parsedAction!.durationDetected || _parsedAction!.categoryDetected)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primarySlateGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'تعرف آلي دقيق',
                              style: TextStyle(fontSize: 10, color: AppTheme.primarySlateGreen),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Editable Title
                    Text(
                      'العنوان المقترح:',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        suffixIcon: const Icon(Icons.edit, size: 16),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Category Selection Chips
                    Text(
                      'التصنيف المستنتج:',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: ActionCategory.values.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        final color = _getCategoryColor(cat);
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: ChoiceChip(
                              label: Text(
                                cat.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.white : color,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: color,
                              backgroundColor: color.withOpacity(0.1),
                              showCheckmark: false,
                              onSelected: (val) {
                                if (val) setState(() => _selectedCategory = cat);
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Duration Selection Chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المدة المستخلصة:',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                          ),
                        ),
                        Text(
                          '$_selectedDuration دقيقة',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primarySlateGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _durationPresets.map((dur) {
                          final isSelected = _selectedDuration == dur;
                          return Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: ChoiceChip(
                              label: Text('$dur د'),
                              selected: isSelected,
                              selectedColor: AppTheme.primarySlateGreen,
                              labelStyle: TextStyle(
                                fontSize: 11,
                                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              ),
                              showCheckmark: false,
                              onSelected: (val) {
                                if (val) setState(() => _selectedDuration = dur);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Prominent 1-Tap Save Button
              ElevatedButton(
                onPressed: _isSaving ? null : _confirmAndSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primarySlateGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'تأكيد الحفظ بلمسة واحدة',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton(
                  onPressed: () {
                    final title = _titleController.text.trim();
                    Navigator.pop(context);
                    LogActionSheet.show(
                      context,
                      initialTitle: title.isNotEmpty ? title : null,
                      initialCategory: _selectedCategory,
                    );
                  },
                  child: const Text(
                    'فتح نافذة التدوين اليدوي التفصيلي',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
