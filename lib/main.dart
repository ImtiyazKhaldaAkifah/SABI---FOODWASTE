import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/app_state.dart';
import 'screens/login_screen.dart'; // 🔴 Import halaman login asli

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://mysjpbluynfpgsitndlm.supabase.co', // Ganti dengan URL kamu
    anonKey: 'sb_publishable_tD6tZSqG0Fq3P4Q5BYhCHw_ZVe360K0', // Ganti dengan Anon Key kamu
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SABI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      navigatorObservers: [routeObserver], 
      home: const LoginScreen(), // 🔴 Halaman Login asli
    );
  }
}