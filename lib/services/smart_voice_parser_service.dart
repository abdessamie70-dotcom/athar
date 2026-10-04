import '../models/action_log_model.dart';

/// Representation of the extracted result from spoken Arabic text
class ParsedVoiceAction {
  final String rawText;
  final String title;
  final int durationMinutes;
  final ActionCategory category;
  final bool durationDetected;
  final bool categoryDetected;

  const ParsedVoiceAction({
    required this.rawText,
    required this.title,
    required this.durationMinutes,
    required this.category,
    this.durationDetected = false,
    this.categoryDetected = false,
  });

  ParsedVoiceAction copyWith({
    String? rawText,
    String? title,
    int? durationMinutes,
    ActionCategory? category,
    bool? durationDetected,
    bool? categoryDetected,
  }) {
    return ParsedVoiceAction(
      rawText: rawText ?? this.rawText,
      title: title ?? this.title,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      category: category ?? this.category,
      durationDetected: durationDetected ?? this.durationDetected,
      categoryDetected: categoryDetected ?? this.categoryDetected,
    );
  }
}

/// Service responsible for parsing transcribed Arabic speech into structured action data:
/// - Duration extraction (formula phrases and numerical minutes)
/// - Automatic category detection based on spiritual keywords
/// - Title sanitization (trimming timing phrases and filler prefixes)
class SmartVoiceParserService {
  /// Arabic number conversion dictionary for text numbers
  static const Map<String, int> _arabicWordNumbers = {
    'خمس': 5,
    'خمسة': 5,
    'عشر': 10,
    'عشرة': 10,
    'خمسة عشر': 15,
    'عشرين': 20,
    'عشرون': 20,
    'خمسة وعشرين': 25,
    'خمس وعشرين': 25,
    'ثلاثين': 30,
    'ثلاثون': 30,
    'أربعين': 40,
    'اربعين': 40,
    'أربعون': 40,
    'اربعون': 40,
    'خمسة وأربعين': 45,
    'خمسة واربعين': 45,
    'خمسين': 50,
    'خمسون': 50,
  };

  /// Main method to parse transcribed Arabic text into a structured `ParsedVoiceAction`
  static ParsedVoiceAction parse(String rawText) {
    final text = rawText.trim();
    if (text.isEmpty) {
      return const ParsedVoiceAction(
        rawText: '',
        title: 'عمل صالح',
        durationMinutes: 30,
        category: ActionCategory.goodDeed,
      );
    }

    // Convert eastern Arabic numerals (٠-٩) to standard (0-9)
    final normalizedText = _normalizeArabicDigits(text);
    final lower = normalizedText.toLowerCase();

    // 1. DURATION EXTRACTION
    int duration = 30; // sensible default
    bool durationDetected = false;

    // Check compound and standard conversational duration phrases first
    if (lower.contains('ساعة ونصف') || lower.contains('ساعة ونص')) {
      duration = 90;
      durationDetected = true;
    } else if (lower.contains('ساعة وربع')) {
      duration = 75;
      durationDetected = true;
    } else if (lower.contains('ساعة وثلث') || lower.contains('ساعة وتلت')) {
      duration = 80;
      durationDetected = true;
    } else if (lower.contains('ساعتين') || lower.contains('ساعتان')) {
      duration = 120;
      durationDetected = true;
    } else if (lower.contains('ثلاث ساعات') || lower.contains('3 ساعات')) {
      duration = 180;
      durationDetected = true;
    } else if (lower.contains('نصف ساعة') || lower.contains('نص ساعة')) {
      duration = 30;
      durationDetected = true;
    } else if (lower.contains('ثلث ساعة') || lower.contains('تلت ساعة')) {
      duration = 20;
      durationDetected = true;
    } else if (lower.contains('ربع ساعة')) {
      duration = 15;
      durationDetected = true;
    } else if (lower.contains('ساعة كاملة') || lower.contains('ساعة')) {
      duration = 60;
      durationDetected = true;
    } else {
      // Check explicit digits pattern: e.g. "20 دقيقة", "45 دقيقة", "10 دقائق"
      final digitRegex = RegExp(r'(\d+)\s*(?:دقيقة|دقائق|د\b)');
      final digitMatch = digitRegex.firstMatch(lower);
      if (digitMatch != null) {
        final parsed = int.tryParse(digitMatch.group(1) ?? '');
        if (parsed != null && parsed > 0) {
          duration = parsed;
          durationDetected = true;
        }
      } else {
        // Check written Arabic word numbers with "دقيقة" or "دقائق"
        for (final entry in _arabicWordNumbers.entries) {
          final wordPattern = RegExp('${entry.key}\\s*(?:دقيقة|دقائق)');
          if (wordPattern.hasMatch(lower)) {
            duration = entry.value;
            durationDetected = true;
            break;
          }
        }
      }
    }

    // 2. CATEGORY AUTO-DETECTION
    // Priority keywords explicitly matching requirement:
    // - Continuous Knowledge: علم، شرح، كود، قراءة، كتاب، درس
    // - Ongoing Charity: صدقة، مال، تبرع، وقف، ماء، كفالة
    // - Good Deed: صلة رحم، مكالمة، زيارة، عيادة، مساعدة، إحسان
    final knowledgeKeywords = [
      'علم', 'شرح', 'كود', 'قراءة', 'كتاب', 'درس',
      'مدارسة', 'بحث', 'محاضرة', 'تلخيص', 'برمجة', 'تعليم',
      'تلاوة', 'حفظ', 'مقال', 'دورة', 'تفسير', 'حديث'
    ];

    final charityKeywords = [
      'صدقة', 'مال', 'تبرع', 'وقف', 'ماء', 'كفالة',
      'بئر', 'سقاية', 'سقيا', 'إطعام', 'طعام', 'كسوة',
      'غرس', 'شجرة', 'شتلة', 'أيتام', 'يتيم', 'مسكين', 'فقير'
    ];

    final deedKeywords = [
      'صلة رحم', 'صلة', 'رحم', 'مكالمة', 'زيارة', 'عيادة',
      'مساعدة', 'إحسان', 'احسان', 'بر', 'والدين', 'والدة', 'والد',
      'إماطة', 'أذى', 'تنظيف', 'إصلاح', 'معروف', 'خدمة', 'تيسير',
      'مريض', 'جيران', 'جار'
    ];

    int knowledgeScore = 0;
    for (final kw in knowledgeKeywords) {
      if (lower.contains(kw)) knowledgeScore++;
    }

    int charityScore = 0;
    for (final kw in charityKeywords) {
      if (lower.contains(kw)) charityScore++;
    }

    int deedScore = 0;
    for (final kw in deedKeywords) {
      if (lower.contains(kw)) deedScore++;
    }

    ActionCategory category = ActionCategory.goodDeed;
    bool categoryDetected = false;

    if (knowledgeScore > charityScore && knowledgeScore > deedScore) {
      category = ActionCategory.continuousKnowledge;
      categoryDetected = true;
    } else if (charityScore > knowledgeScore && charityScore > deedScore) {
      category = ActionCategory.ongoingCharity;
      categoryDetected = true;
    } else if (deedScore > 0) {
      category = ActionCategory.goodDeed;
      categoryDetected = true;
    } else {
      // Fallback detection
      if (knowledgeScore > 0) {
        category = ActionCategory.continuousKnowledge;
        categoryDetected = true;
      } else if (charityScore > 0) {
        category = ActionCategory.ongoingCharity;
        categoryDetected = true;
      } else {
        category = ActionCategory.goodDeed;
        categoryDetected = false;
      }
    }

    // 3. TITLE SANITIZATION (Trimming timing phrases and filler prefixes)
    String cleanedTitle = text;

    final removalList = [
      // Compound phrases
      'لمدة ساعة ونصف', 'ساعة ونصف', 'ساعة ونص',
      'لمدة ساعة وربع', 'ساعة وربع',
      'لمدة ساعة وثلث', 'ساعة وثلث', 'ساعة وتلت',
      'لمدة ساعتين', 'ساعتين', 'ساعتان',
      'لمدة ثلاث ساعات', 'ثلاث ساعات', '3 ساعات',
      'لمدة نصف ساعة', 'نصف ساعة', 'نص ساعة',
      'لمدة ثلث ساعة', 'ثلث ساعة', 'تلت ساعة',
      'لمدة ربع ساعة', 'ربع ساعة',
      'لمدة ساعة كاملة', 'ساعة كاملة', 'لمدة ساعة', 'ساعة',
      // Regex removals
      RegExp(r'لمدة\s+\d+\s*(?:دقيقة|دقائق|د\b)'),
      RegExp(r'\b\d+\s*(?:دقيقة|دقائق|د\b)'),
      RegExp(r'\s+لمدة\s*$'),
      RegExp(r'^\s*قمت بـ\s*'),
      RegExp(r'^\s*قمت ب\s*'),
      RegExp(r'^\s*عملت\s*'),
      RegExp(r'^\s*سويت\s*'),
      RegExp(r'^\s*جلست\s*'),
      RegExp(r'^\s*سجلت\s*'),
    ];

    for (final pattern in removalList) {
      if (pattern is String) {
        cleanedTitle = cleanedTitle.replaceAll(pattern, '');
      } else if (pattern is RegExp) {
        cleanedTitle = cleanedTitle.replaceAll(pattern, '');
      }
    }

    // Clean any word number phrases with دقيقة if remaining
    for (final kw in _arabicWordNumbers.keys) {
      cleanedTitle = cleanedTitle.replaceAll(RegExp('لمدة\\s*$kw\\s*(?:دقيقة|دقائق)'), '');
      cleanedTitle = cleanedTitle.replaceAll(RegExp('$kw\\s*(?:دقيقة|دقائق)'), '');
    }

    // Remove dangling punctuation or excess whitespace
    cleanedTitle = cleanedTitle
        .replaceAll(RegExp(r'[,،.\-–—]+$'), '')
        .replaceAll(RegExp(r'^[,،.\-–—]+'), '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();

    if (cleanedTitle.isEmpty) {
      cleanedTitle = text;
    }

    return ParsedVoiceAction(
      rawText: text,
      title: cleanedTitle,
      durationMinutes: duration,
      category: category,
      durationDetected: durationDetected,
      categoryDetected: categoryDetected,
    );
  }

  /// Converts Eastern Arabic numerals (٠-٩) to standard Western digits (0-9)
  static String _normalizeArabicDigits(String input) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String output = input;
    for (int i = 0; i < arabicDigits.length; i++) {
      output = output.replaceAll(arabicDigits[i], i.toString());
    }
    return output;
  }
}
