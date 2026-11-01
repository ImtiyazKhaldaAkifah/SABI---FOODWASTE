import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config.dart';
import 'core/theme.dart';
import 'screens/login_screen.dart';
import 'screens/shell.dart';
import 'services/app_state.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  if (AppConfig.ready) {
    await Supabase.initialize(url: AppConfig.supabaseUrl, anonKey: AppConfig.supabaseAnonKey);
  }
  final state = AppState();
  await state.init();
  final user = await AuthService.current();
  runApp(ChangeNotifierProvider.value(value: state, child: SabiApp(loggedIn: user != null)));
}

class SabiApp extends StatelessWidget {
  final bool loggedIn;
  const SabiApp({super.key, required this.loggedIn});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'SABI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: C.teal), useMaterial3: true),
        home: loggedIn ? const Shell() : const LoginScreen(),
      );
}