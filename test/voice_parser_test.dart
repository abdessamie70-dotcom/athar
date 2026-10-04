import 'package:flutter_test/flutter_test.dart';
import 'package:athar/models/action_log_model.dart';
import 'package:athar/services/voice_input_service.dart';

void main() {
  group('Arabic Voice Parsing Tests (Natural Language to Action)', () {
    test('should parse "شرح درس لزميلي نصف ساعة" correctly', () {
      final parsed = VoiceInputService.parseSpokenArabicAction('شرح درس لزميلي نصف ساعة');

      expect(parsed.title, equals('شرح درس لزميلي'));
      expect(parsed.durationMinutes, equals(30));
      expect(parsed.category, equals(ActionCategory.continuousKnowledge));
    });

    test('should parse "سقيا ماء لعمال الحي ساعة" correctly', () {
      final parsed = VoiceInputService.parseSpokenArabicAction('سقيا ماء لعمال الحي ساعة');

      expect(parsed.title, equals('سقيا ماء لعمال الحي'));
      expect(parsed.durationMinutes, equals(60));
      expect(parsed.category, equals(ActionCategory.ongoingCharity));
    });

    test('should parse "صلة رحم وزيارة الوالدة ساعتين" correctly', () {
      final parsed = VoiceInputService.parseSpokenArabicAction('صلة رحم وزيارة الوالدة ساعتين');

      expect(parsed.title, equals('صلة رحم وزيارة الوالدة'));
      expect(parsed.durationMinutes, equals(120));
      expect(parsed.category, equals(ActionCategory.goodDeed));
    });

    test('should parse explicit numeric minutes like "كتابة وتوثيق حل برمجي 45 دقيقة"', () {
      final parsed = VoiceInputService.parseSpokenArabicAction('كتابة وتوثيق حل برمجي 45 دقيقة');

      expect(parsed.title, equals('كتابة وتوثيق حل برمجي'));
      expect(parsed.durationMinutes, equals(45));
      expect(parsed.category, equals(ActionCategory.continuousKnowledge));
    });

    test('should parse "غرس شتلة نبتة نافعة ربع ساعة"', () {
      final parsed = VoiceInputService.parseSpokenArabicAction('غرس شتلة نبتة نافعة ربع ساعة');

      expect(parsed.title, equals('غرس شتلة نبتة نافعة'));
      expect(parsed.durationMinutes, equals(15));
      expect(parsed.category, equals(ActionCategory.ongoingCharity));
    });

    test('should provide safe defaults for empty input', () {
      final parsed = VoiceInputService.parseSpokenArabicAction('');

      expect(parsed.title, isNotEmpty);
      expect(parsed.durationMinutes, equals(30));
      expect(parsed.category, equals(ActionCategory.goodDeed));
    });
  });
}
