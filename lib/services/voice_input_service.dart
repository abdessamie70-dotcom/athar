import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'smart_voice_parser_service.dart';

export 'smart_voice_parser_service.dart';

enum VoicePermissionState {
  granted,
  denied,
  permanentlyDenied,
  restricted,
}

/// Service that coordinates microphone permissions, speech recognition via speech_to_text,
/// and delegates Arabic natural language parsing to SmartVoiceParserService.
class VoiceInputService {
  final stt.SpeechToText _speechToText;
  bool _isInitialized = false;

  VoiceInputService({stt.SpeechToText? speechToText})
      : _speechToText = speechToText ?? stt.SpeechToText();

  bool get isListening => _speechToText.isListening;
  bool get isAvailable => _isInitialized;

  /// Checks microphone permission and requests it if not yet determined.
  Future<VoicePermissionState> checkAndRequestMicrophonePermission() async {
    final currentStatus = await Permission.microphone.status;

    if (currentStatus.isGranted) {
      return VoicePermissionState.granted;
    }

    if (currentStatus.isPermanentlyDenied) {
      return VoicePermissionState.permanentlyDenied;
    }

    if (currentStatus.isRestricted) {
      return VoicePermissionState.restricted;
    }

    // Request permission from system
    final requestedStatus = await Permission.microphone.request();

    if (requestedStatus.isGranted) {
      return VoicePermissionState.granted;
    } else if (requestedStatus.isPermanentlyDenied) {
      return VoicePermissionState.permanentlyDenied;
    } else {
      return VoicePermissionState.denied;
    }
  }

  /// Opens the device settings page for the app
  Future<bool> openPhoneSettings() async {
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.settings);
      return true;
    } catch (_) {
      return await openAppSettings();
    }
  }

  /// Initializes the speech recognition engine
  Future<bool> initializeSpeech() async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          // Speech error handled via listeners
        },
        onStatus: (status) {
          // Speech status updates
        },
      );
      return _isInitialized;
    } catch (_) {
      return false;
    }
  }

  /// Starts listening to speech in Arabic
  Future<void> startListening({
    required Function(String text) onResult,
    String preferredLocaleId = 'ar_SA',
  }) async {
    if (!_isInitialized) {
      final ok = await initializeSpeech();
      if (!ok) {
        throw Exception('تعذر تهيئة التعرف على الصوت. يرجى التحقق من دعم جهازك.');
      }
    }

    // Find best available Arabic locale
    String localeToUse = 'ar';
    try {
      final locales = await _speechToText.locales();
      final hasArabic = locales.any((l) => l.localeId.startsWith('ar'));
      if (hasArabic) {
        final saLocale = locales.firstWhere(
          (l) => l.localeId.toLowerCase().contains('sa') || l.localeId.startsWith('ar'),
          orElse: () => locales.firstWhere((l) => l.localeId.startsWith('ar')),
        );
        localeToUse = saLocale.localeId;
      }
    } catch (_) {
      localeToUse = preferredLocaleId;
    }

    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      localeId: localeToUse,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      cancelOnError: false,
      partialResults: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  /// Stops active listening
  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  /// Cancels listening without committing results
  Future<void> cancelListening() async {
    if (_speechToText.isListening) {
      await _speechToText.cancel();
    }
  }

  /// Parses spoken Arabic text into Title, Duration, and ActionCategory.
  /// Delegates directly to SmartVoiceParserService.
  static ParsedVoiceAction parseSpokenArabicAction(String rawText) {
    return SmartVoiceParserService.parse(rawText);
  }
}
