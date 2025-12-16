import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
// ...existing code...
import 'services/theme_provider.dart';
import 'services/notes_provider.dart';
import 'services/folders_provider.dart';
import 'services/auth_provider.dart';

void main() {
  // Set preferred orientations and optimizations
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => NotesProvider()),
        ChangeNotifierProvider(create: (context) => FoldersProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: const CloudInkApp(),
    ),
  );
}

class CloudInkApp extends StatelessWidget {
  const CloudInkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Cloudink',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          // بعد إزالة شاشة البداية، اجعل شاشة تسجيل الدخول أو الرئيسية هي أول شاشة
          home: const LoginScreen(),
        );
      },
    );
  }
}
