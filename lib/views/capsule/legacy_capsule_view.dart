import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controllers/athar_provider.dart';
import '../../models/legacy_capsule_model.dart';
import '../../theme/app_theme.dart';

class LegacyCapsuleView extends StatefulWidget {
  const LegacyCapsuleView({super.key});

  @override
  State<LegacyCapsuleView> createState() => _LegacyCapsuleViewState();
}

class _LegacyCapsuleViewState extends State<LegacyCapsuleView> {
  final TextEditingController _passphraseController = TextEditingController();
  bool _obscurePassphrase = true;

  @override
  void dispose() {
    _passphraseController.dispose();
    super.dispose();
  }

  void _showAddEntrySheet(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final passphraseController = TextEditingController();
    CapsuleType selectedType = CapsuleType.reflection;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
            child: SingleChildScrollView(
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
                  Row(
                    children: [
                      const Icon(Icons.enhanced_encryption_rounded, color: AppTheme.accentGold),
                      const SizedBox(width: 8),
                      Text(
                        'إيداع في كبسولة الأثر المشفرة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.textLight : AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'يتم تشفير هذا المحتوى محلياً بتقنية AES-256 قبل حفظه ولا يمكن فك تشفيره بدون عبارة المرور.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Capsule Type
                  DropdownButtonFormField<CapsuleType>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'نوع الإيداع'),
                    items: CapsuleType.values.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(t.label),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setSheetState(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان الكبسولة',
                      hintText: 'مثال: وصية للأبناء، خلاصة تجربة في الحياة...',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: contentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'نص الرسالة / الوصية',
                      hintText: 'اكتب ما تود تركه لمن بعدك بصدق وبصيرة...',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: passphraseController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'عبارة المرور للتشفير (Passphrase)',
                      hintText: 'احفظ هذه العبارة جيداً، لا يمكن استرجاع النص بدونها',
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      final content = contentController.text.trim();
                      final pass = passphraseController.text.trim();

                      if (title.isEmpty || content.isEmpty || pass.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
                        );
                        return;
                      }

                      final success = await context.read<AtharProvider>().addCapsuleEntry(
                            title: title,
                            plainContent: content,
                            type: selectedType,
                            passphrase: pass,
                          );

                      if (mounted) {
                        if (success) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم تشفير الإيداع وحفظه في كبسولة الأثر بنجاح'),
                              backgroundColor: AppTheme.primarySlateGreen,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تعذر حفظ الكبسولة')),
                          );
                        }
                      }
                    },
                    child: const Text('تشفير وحفظ في الخزنة'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AtharProvider>(
      builder: (context, provider, _) {
        final isUnlocked = provider.isCapsuleUnlocked;
        final capsules = provider.capsules;

        return Scaffold(
          appBar: AppBar(
            title: const Text('كبسولة الأثر والوصايا'),
            actions: [
              if (isUnlocked)
                IconButton(
                  icon: const Icon(Icons.lock_rounded),
                  tooltip: 'قفل الخزنة',
                  onPressed: () => provider.lockCapsule(),
                ),
            ],
          ),
          floatingActionButton: isUnlocked
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddEntrySheet(context),
                  backgroundColor: AppTheme.accentGoldDark,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_moderator_rounded),
                  label: const Text('إيداع جديد'),
                )
              : null,
          body: !isUnlocked
              ? Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? const Color(0xFF28362E) : const Color(0xFFE8E4DA),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_person_rounded,
                              size: 36,
                              color: AppTheme.accentGold,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'خزنة الأثر المشفرة',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.textLight : AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'مستودع آمن ومحمي بتشفير AES-256 لوصاياك وتأملاتك للأجيال القادمة. أدخل عبارة المرور لفك تشفير المحتوى.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _passphraseController,
                            obscureText: _obscurePassphrase,
                            decoration: InputDecoration(
                              labelText: 'عبارة المرور الخاصة بك',
                              hintText: 'كلمة المرور المشتق منها مفتاح التشفير',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassphrase ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassphrase = !_obscurePassphrase);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                final pass = _passphraseController.text.trim();
                                if (pass.isEmpty) return;

                                final success = provider.unlockCapsule(pass);
                                if (!success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('عبارة المرور غير صحيحة أو تعذر فك التشفير'),
                                      backgroundColor: Colors.brown,
                                    ),
                                  );
                                }
                              },
                              child: const Text('فتح الخزنة واستعراض الوصايا'),
                            ),
                          ),
                          if (capsules.isEmpty) ...[
                            const SizedBox(height: 14),
                            TextButton(
                              onPressed: () => _showAddEntrySheet(context),
                              child: const Text('إنشاء أول إيداع مشفر الآن'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_open_rounded, color: AppTheme.accentGold, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'الخزنة مفتوحة ومحتواها مفكوك التشفير محلياً على جهازك.',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppTheme.accentGoldLight : AppTheme.accentGoldDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (capsules.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        alignment: Alignment.center,
                        child: Text(
                          'لا توجد وصايا أو تأملات محفوظة بعد.\nاضغط "إيداع جديد" لإضافة أول كبسولة مشفرة.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                          ),
                        ),
                      )
                    else
                      ...capsules.map((c) {
                        final decrypted = provider.getDecryptedContent(c.capsuleId);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
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
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primarySlateGreen.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          c.type.label,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.primarySlateGreen,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        DateFormat('yyyy/MM/dd').format(c.updatedAt),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                    color: Colors.red[300],
                                    onPressed: () => provider.deleteCapsule(c.capsuleId),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                c.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppTheme.textLight : AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                decrypted ?? 'محتوى مشفر (يتطلب كلمة المرور)',
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: decrypted != null
                                      ? (isDark ? AppTheme.textLight : AppTheme.textDark)
                                      : Colors.grey,
                                  fontStyle: decrypted == null ? FontStyle.italic : FontStyle.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
        );
      },
    );
  }
}
