import 'package:flutter/material.dart';
import '../../../services/voice_input_service.dart';
import '../../../theme/app_theme.dart';

class VoicePermissionDialog extends StatelessWidget {
  final VoiceInputService voiceService;

  const VoicePermissionDialog({
    super.key,
    required this.voiceService,
  });

  static Future<void> show(BuildContext context, VoiceInputService voiceService) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => VoicePermissionDialog(voiceService: voiceService),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? const Color(0xFF28362E) : const Color(0xFFE8E4DA),
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mic_off_rounded,
              color: AppTheme.accentGold,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'صلاحية الميكروفون مطلوبة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textLight : AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'يحتاج تطبيق "أثر باقٍ" لإذن الميكروفون لتمكينك من تدوين أعمالك الصالحة بصوتك وتحويلها إلى أثر مسجل في صحيفتك بسهولة وسرعة.',
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF232D28) : const Color(0xFFF7F4EE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.primarySlateGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تم رفض الإذن سابقاً، يمكنك تفعيله الآن مباشرة من إعدادات الهاتف.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppTheme.textLight : AppTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'لاحقاً',
            style: TextStyle(
              color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(context);
            await voiceService.openPhoneSettings();
          },
          icon: const Icon(Icons.settings_outlined, size: 18),
          label: const Text('فتح إعدادات الهاتف'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primarySlateGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
