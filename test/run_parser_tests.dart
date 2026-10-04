import '../lib/services/smart_voice_parser_service.dart';
import '../lib/models/action_log_model.dart';

void main() {
  print('=== STARTING SMART VOICE PARSER TESTS ===');

  // Test 1: Duration extraction
  final d1 = SmartVoiceParserService.parse('قراءة كتاب نصف ساعة');
  assert(d1.durationMinutes == 30, 'Expected 30 mins for نصف ساعة, got ${d1.durationMinutes}');
  print('✓ Test 1 Passed: نصف ساعة -> 30 mins');

  final d2 = SmartVoiceParserService.parse('مساعدة جار ربع ساعة');
  assert(d2.durationMinutes == 15, 'Expected 15 mins for ربع ساعة, got ${d2.durationMinutes}');
  print('✓ Test 2 Passed: ربع ساعة -> 15 mins');

  final d3 = SmartVoiceParserService.parse('مكالمة صلة رحم ثلث ساعة');
  assert(d3.durationMinutes == 20, 'Expected 20 mins for ثلث ساعة, got ${d3.durationMinutes}');
  print('✓ Test 3 Passed: ثلث ساعة -> 20 mins');

  final d4 = SmartVoiceParserService.parse('شرح درس ساعة');
  assert(d4.durationMinutes == 60, 'Expected 60 mins for ساعة, got ${d4.durationMinutes}');
  print('✓ Test 4 Passed: ساعة -> 60 mins');

  final d5 = SmartVoiceParserService.parse('كتابة كود برمجي ساعة ونصف');
  assert(d5.durationMinutes == 90, 'Expected 90 mins for ساعة ونصف, got ${d5.durationMinutes}');
  print('✓ Test 5 Passed: ساعة ونصف -> 90 mins');

  final d6 = SmartVoiceParserService.parse('زيارة عيادة مريض ساعتين');
  assert(d6.durationMinutes == 120, 'Expected 120 mins for ساعتين, got ${d6.durationMinutes}');
  print('✓ Test 6 Passed: ساعتين -> 120 mins');

  final d7 = SmartVoiceParserService.parse('تبرع بالمال 20 دقيقة');
  assert(d7.durationMinutes == 20, 'Expected 20 mins for 20 دقيقة, got ${d7.durationMinutes}');
  print('✓ Test 7 Passed: 20 دقيقة -> 20 mins');

  // Test 2: Category auto-detection
  // continuous_knowledge keywords: علم، شرح، كود، قراءة، كتاب، درس
  final knowledgeKeywords = ['علم', 'شرح', 'كود', 'قراءة', 'كتاب', 'درس'];
  for (final kw in knowledgeKeywords) {
    final parsed = SmartVoiceParserService.parse('قمت بإنجاز $kw نافع لمدة نصف ساعة');
    assert(parsed.category == ActionCategory.continuousKnowledge, 'Failed category for $kw');
  }
  print('✓ Test 8 Passed: All continuous_knowledge keywords auto-detected');

  // ongoing_charity keywords: صدقة، مال، تبرع، وقف، ماء، كفالة
  final charityKeywords = ['صدقة', 'مال', 'تبرع', 'وقف', 'ماء', 'كفالة'];
  for (final kw in charityKeywords) {
    final parsed = SmartVoiceParserService.parse('مبادرة $kw للفقراء 15 دقيقة');
    assert(parsed.category == ActionCategory.ongoingCharity, 'Failed category for $kw');
  }
  print('✓ Test 9 Passed: All ongoing_charity keywords auto-detected');

  // good_deed keywords: صلة رحم، مكالمة، زيارة، عيادة، مساعدة، إحسان
  final deedKeywords = ['صلة رحم', 'مكالمة', 'زيارة', 'عيادة', 'مساعدة', 'إحسان'];
  for (final kw in deedKeywords) {
    final parsed = SmartVoiceParserService.parse('عمل $kw للأسرة والأهل ساعة');
    assert(parsed.category == ActionCategory.goodDeed, 'Failed category for $kw');
  }
  print('✓ Test 10 Passed: All good_deed keywords auto-detected');

  // Test 3: Title Sanitization
  final t1 = SmartVoiceParserService.parse('شرح درس لزميلي نصف ساعة');
  assert(t1.title == 'شرح درس لزميلي', 'Expected "شرح درس لزميلي", got "${t1.title}"');
  print('✓ Test 11 Passed: Title trimmed duration suffix: "${t1.title}"');

  final t2 = SmartVoiceParserService.parse('قمت بـ تبرع مال لدار الأيتام لمدة 20 دقيقة');
  assert(t2.title == 'تبرع مال لدار الأيتام', 'Expected "تبرع مال لدار الأيتام", got "${t2.title}"');
  print('✓ Test 12 Passed: Title trimmed prefix and duration: "${t2.title}"');

  print('=== ALL 12 TESTS PASSED SUCCESSFULLY! ===');
}
