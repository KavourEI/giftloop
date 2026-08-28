import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await NotificationService.init();
  runApp(const GiftLoopApp());
}

class GiftLoopApp extends StatelessWidget {
  const GiftLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GiftLoop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}
