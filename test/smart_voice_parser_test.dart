import 'package:flutter_test/flutter_test.dart';
import 'package:athar/models/action_log_model.dart';
import 'package:athar/services/smart_voice_parser_service.dart';

void main() {
  group('SmartVoiceParserService Comprehensive Tests', () {
    test('extracts duration formulas accurately', () {
      // نصف ساعة -> 30 دقيقة
      expect(
        SmartVoiceParserService.parse('قراءة كتاب نصف ساعة').durationMinutes,
        equals(30),
      );

      // ربع ساعة -> 15 دقيقة
      expect(
        SmartVoiceParserService.parse('مساعدة جار ربع ساعة').durationMinutes,
        equals(15),
      );

      // ثلث ساعة -> 20 دقيقة
      expect(
        SmartVoiceParserService.parse('مكالمة صلة رحم ثلث ساعة').durationMinutes,
        equals(20),
      );

      // ساعة -> 60 دقيقة
      expect(
        SmartVoiceParserService.parse('شرح درس ساعة').durationMinutes,
        equals(60),
      );

      // ساعة ونصف -> 90 دقيقة
      expect(
        SmartVoiceParserService.parse('كتابة كود برمجي ساعة ونصف').durationMinutes,
        equals(90),
      );

      // ساعتين -> 120 دقيقة
      expect(
        SmartVoiceParserService.parse('زيارة عيادة مريض ساعتين').durationMinutes,
        equals(120),
      );

      // 20 دقيقة صريحة
      expect(
        SmartVoiceParserService.parse('تبرع بالمال 20 دقيقة').durationMinutes,
        equals(20),
      );
    });

    test('auto-detects continuous_knowledge category from specified keywords', () {
      final keywords = ['علم', 'شرح', 'كود', 'قراءة', 'كتاب', 'درس'];
      for (final kw in keywords) {
        final parsed = SmartVoiceParserService.parse('قمت بإنجاز $kw نافع لمدة نصف ساعة');
        expect(
          parsed.category,
          equals(ActionCategory.continuousKnowledge),
          reason: 'Failed for keyword: $kw',
        );
      }
    });

    test('auto-detects ongoing_charity category from specified keywords', () {
      final keywords = ['صدقة', 'مال', 'تبرع', 'وقف', 'ماء', 'كفالة'];
      for (final kw in keywords) {
        final parsed = SmartVoiceParserService.parse('مبادرة $kw للفقراء 15 دقيقة');
        expect(
          parsed.category,
          equals(ActionCategory.ongoingCharity),
          reason: 'Failed for keyword: $kw',
        );
      }
    });

    test('auto-detects good_deed category from specified keywords', () {
      final keywords = ['صلة رحم', 'مكالمة', 'زيارة', 'عيادة', 'مساعدة', 'إحسان'];
      for (final kw in keywords) {
        final parsed = SmartVoiceParserService.parse('عمل $kw للأسرة والأهل ساعة');
        expect(
          parsed.category,
          equals(ActionCategory.goodDeed),
          reason: 'Failed for keyword: $kw',
        );
      }
    });

    test('sanitizes title by trimming timing phrases and filler prefixes', () {
      final sample1 = SmartVoiceParserService.parse('شرح درس لزميلي نصف ساعة');
      expect(sample1.title, equals('شرح درس لزميلي'));

      final sample2 = SmartVoiceParserService.parse('قمت بـ تبرع مال لدار الأيتام لمدة 20 دقيقة');
      expect(sample2.title, equals('تبرع مال لدار الأيتام'));

      final sample3 = SmartVoiceParserService.parse('عملت مكالمة صلة رحم مع أختي ساعة ونصف');
      expect(sample3.title, equals('مكالمة صلة رحم مع أختي'));
    });
  });
}
