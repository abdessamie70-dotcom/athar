import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'controllers/athar_provider.dart';
import 'repositories/local/local_action_log_repository.dart';
import 'repositories/local/local_daily_metrics_repository.dart';
import 'repositories/local/local_initiatives_repository.dart';
import 'repositories/local/local_legacy_capsule_repository.dart';
import 'services/home_widget_service.dart';
import 'services/local_storage_service.dart';
import 'services/voice_input_service.dart';
import 'theme/app_theme.dart';
import 'views/action_logging/voice_action_sheet.dart';
import 'views/main_navigation_screen.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void _handleWidgetDeepLink(Uri? uri) {
  if (HomeWidgetService.isVoiceActionUri(uri)) {
    // Defer slightly to ensure navigator and context are mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = appNavigatorKey.currentContext;
      if (context != null) {
        VoiceActionSheet.show(context, VoiceInputService());
      }
    });
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline storage service
  final storage = await LocalStorageService.create();

  // Initialize repositories
  final metricsRepo = LocalDailyMetricsRepository(storage);
  final actionLogRepo = LocalActionLogRepository(storage, metricsRepo);
  final initiativesRepo = LocalInitiativesRepository(storage);
  final capsuleRepo = LocalLegacyCapsuleRepository(storage);

  final atharProvider = AtharProvider(
    storage: storage,
    actionLogRepo: actionLogRepo,
    metricsRepo: metricsRepo,
    initiativesRepo: initiativesRepo,
    capsuleRepo: capsuleRepo,
  );

  await atharProvider.initialize();

  // Initialize Home Screen Widget and listen for deep links
  await HomeWidgetService.initialize(onUriReceived: _handleWidgetDeepLink);
  await HomeWidgetService.updateWidgetData(
    lastingMinutes: atharProvider.todayMetric.lastingTimeMinutes,
  );

  runApp(
    ChangeNotifierProvider<AtharProvider>.value(
      value: atharProvider,
      child: const AtharApp(),
    ),
  );
}

class AtharApp extends StatelessWidget {
  const AtharApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AtharProvider>(
      builder: (context, provider, _) {
        final isDark = provider.user.preferences.darkMode;

        return MaterialApp(
          navigatorKey: appNavigatorKey,
          title: 'أثر باقٍ',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          locale: const Locale('ar'),
          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}
