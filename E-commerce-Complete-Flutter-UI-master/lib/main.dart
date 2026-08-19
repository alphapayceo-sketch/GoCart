import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/route/router.dart' as router;
import 'package:shop/services/notification_socket_service.dart';
import 'package:shop/theme/app_theme.dart';

const String _kSeenOnboarding = 'seenOnboarding';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationSocketService.initialize();

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool(_kSeenOnboarding) ?? false;

  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.hasSeenOnboarding});

  final bool hasSeenOnboarding;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StyleHub',
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: ThemeMode.system,
      onGenerateRoute: router.generateRoute,
      initialRoute: hasSeenOnboarding ? logInScreenRoute : onbordingScreenRoute,
    );
  }
}
