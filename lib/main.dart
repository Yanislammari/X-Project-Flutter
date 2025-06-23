import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:x_project_flutter/home_screen/home_screen.dart';
import 'package:x_project_flutter/login_screen/login_email_passwd_screen.dart';
import 'package:x_project_flutter/register_screen/chose_email_screen.dart';
import 'package:x_project_flutter/register_screen/chose_password_screen.dart';
import 'l10n/generated/app_localizations.dart';
import 'l10n/l10n.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'login_screen/chose_login_screen.dart';
import 'on_board_screen/onboarding_description_screen.dart';
import 'on_board_screen/onboarding_image_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.all,
      theme: ThemeData(
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 23,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            fontSize: 17,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
          labelSmall: TextStyle(
            fontSize: 14,
            color: Colors.blue,
            decoration: TextDecoration.underline, // Apply underline
          ),
        ),
      ),
      routes:{
        Login.routeName: (context) => const Login(),
        LoginEmailPasswdScreen.routeName : (context) => const LoginEmailPasswdScreen(),
        ChoseEmailScreen.routeName : (context) => const ChoseEmailScreen(),
        OnboardingDescriptionScreen.routeName: (context) => const OnboardingDescriptionScreen(),
        OnboardingImageScreen.routeName: (context) => const OnboardingImageScreen(),
        ChosePasswordScreen.routeName: (context) => const ChosePasswordScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
      },
      onGenerateRoute: (RouteSettings settings) {
        switch(settings.name) {
          case '/password':
            return MaterialPageRoute(
              builder: (context) => const Login(),
            );

          default: return null;
        }
      },
    );
  }
}
