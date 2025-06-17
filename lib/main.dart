import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:docsave_flutter/providers/auth_provider.dart';
import 'package:docsave_flutter/providers/document_provider.dart';
import 'package:docsave_flutter/screens/splash_screen.dart';
import 'package:docsave_flutter/screens/auth/login_screen.dart';
import 'package:docsave_flutter/screens/auth/register_screen.dart';
import 'package:docsave_flutter/screens/home/home_screen.dart';
import 'package:docsave_flutter/utils/theme.dart';

void main() {
  runApp(const DocSaveApp());
}

class DocSaveApp extends StatelessWidget {
  const DocSaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
      ],
      child: MaterialApp(
        title: 'DocSave',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
