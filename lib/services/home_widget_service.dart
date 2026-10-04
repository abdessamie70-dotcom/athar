import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Service responsible for managing Home Screen Widget synchronization,
/// daily rotating deed ideas, and handling widget launch / deep link callbacks.
class HomeWidgetService {
  static const String androidWidgetProvider = 'AtharWidgetProvider';
  static const String iOSWidgetKind = 'AtharWidget';
  static const String appGroupId = 'group.com.athar.app';

  static const String keyLastingMinutes = 'lasting_minutes';
  static const String keyLastingMinutesNum = 'lasting_minutes_num';
  static const String keyDailyQuote = 'daily_quote';
  static const String keyLastUpdated = 'last_updated';

  /// Scheme and host used for deep linking from the widget
  static const String voiceActionScheme = 'athar';
  static const String voiceActionHost = 'voice_action';
  static final Uri voiceActionUri = Uri(scheme: voiceActionScheme, host: voiceActionHost);

  /// Rotating inspiring deed ideas and spiritual reminders
  static const List<String> dailyDeedIdeas = [
    'سقيا ماء أو بذل صدقة خفية أثر يمتد ولا ينقطع.',
    'شرح مسألة علمية أو إعانة طالب علم غرسٌ باقٍ.',
    'صلة رحم بمكالمة دافئة تنمي العمر وتبارك في الأثر.',
    'إماطة أذى عن طريق أو كلمة طيبة تزرع أملاً.',
    'تلاوة آيات وتدبرها وبث علم نافع صدقة جارية.',
    'إطعام طعام أو إدخال سرور على قلب مسلم ثواب يدوم.',
    'الدعاء بظهر الغيب لمن تحب عمل خفي أثره عظيم.',
  ];

  static StreamSubscription<Uri?>? _widgetClickSubscription;

  /// Initializes widget group and listens for clicks / deep links
  static Future<void> initialize({Function(Uri? uri)? onUriReceived}) async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);

      if (onUriReceived != null) {
        // Handle click when app is already running or brought to foreground
        _widgetClickSubscription?.cancel();
        _widgetClickSubscription = HomeWidget.widgetClicked.listen((Uri? uri) {
          debugPrint('HomeWidget clicked: $uri');
          onUriReceived(uri);
        });

        // Check if app was initially opened from home widget
        final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
        if (initialUri != null) {
          debugPrint('HomeWidget initial launch: $initialUri');
          onUriReceived(initialUri);
        }
      }
    } catch (e) {
      debugPrint('Error initializing HomeWidgetService: $e');
    }
  }

  /// Returns today's rotating inspiring quote
  static String getTodayQuote() {
    final now = DateTime.now();
    final index = (now.year * 365 + now.month * 31 + now.day) % dailyDeedIdeas.length;
    return dailyDeedIdeas[index];
  }

  /// Updates data displayed on the Home Screen Widget
  static Future<void> updateWidgetData({
    required int lastingMinutes,
    String? quote,
  }) async {
    try {
      final selectedQuote = quote ?? getTodayQuote();

      // Save shared preferences data readable by native widget
      await HomeWidget.saveWidgetData<String>(
        keyLastingMinutes,
        '$lastingMinutes دقيقة',
      );
      await HomeWidget.saveWidgetData<int>(
        keyLastingMinutesNum,
        lastingMinutes,
      );
      await HomeWidget.saveWidgetData<String>(
        keyDailyQuote,
        selectedQuote,
      );
      await HomeWidget.saveWidgetData<String>(
        keyLastUpdated,
        'اليوم ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      );

      // Trigger update on native widget provider
      await HomeWidget.updateWidget(
        name: androidWidgetProvider,
        androidName: androidWidgetProvider,
        iOSName: iOSWidgetKind,
      );

      debugPrint('HomeWidget updated successfully with $lastingMinutes lasting minutes.');
    } catch (e) {
      debugPrint('Failed to update HomeWidget: $e');
    }
  }

  /// Checks if given URI targets the rapid voice action sheet
  static bool isVoiceActionUri(Uri? uri) {
    if (uri == null) return false;
    return uri.scheme == voiceActionScheme && uri.host == voiceActionHost;
  }

  static void dispose() {
    _widgetClickSubscription?.cancel();
  }
}
