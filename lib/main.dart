import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'l10n/strings.dart';
import 'services/image_service.dart';
import 'services/notification_service.dart';
import 'services/people_store.dart';
import 'services/settings_service.dart';
import 'services/share_service.dart';
import 'utils/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/import_shared_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final messengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await initializeDateFormatting();
  await SettingsService.instance.load();
  await ImageService.init();
  await NotificationService.init();
  runApp(const GiftLoopApp());
}

class GiftLoopApp extends StatefulWidget {
  const GiftLoopApp({super.key});

  @override
  State<GiftLoopApp> createState() => _GiftLoopAppState();
}

class _GiftLoopAppState extends State<GiftLoopApp> with WidgetsBindingObserver {
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PeopleStore.instance.load();
    if (!kIsWeb) {
      // Emits the link that launched the app too, then any later ones.
      _linkSub = AppLinks().uriLinkStream.listen(_handleLink);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only the soonest reminders fit in the iOS notification limit, so top
    // them up whenever the app comes back.
    if (state == AppLifecycleState.resumed && PeopleStore.instance.isLoaded) {
      PeopleStore.instance.refreshReminders();
    }
  }

  Future<void> _handleLink(Uri uri) async {
    if (!ShareService.isShareLink(uri)) return;
    await PeopleStore.instance.load();
    final card = ShareService.parse(uri.toString());
    // Wait for the first frame so the navigator exists on a cold start.
    await WidgetsBinding.instance.endOfFrame;
    if (card == null) {
      messengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(S.current.invalidShareLink)));
      return;
    }
    navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (_) => ImportSharedScreen(card: card),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsService.instance,
      builder: (context, _) => MaterialApp(
        title: 'GiftLoop',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: messengerKey,
        locale: Locale(SettingsService.instance.language),
        supportedLocales:
            S.supportedLanguages.map((l) => Locale(l)).toList(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const HomeScreen(),
      ),
    );
  }
}
