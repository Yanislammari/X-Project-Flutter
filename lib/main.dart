import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:x_project_flutter/core/blocs/on_boarding_bloc/on_boarding_bloc.dart';
import 'package:x_project_flutter/core/blocs/register_bloc/register_bloc.dart';
import 'package:x_project_flutter/core/repositories/login/firebase_login_data_source.dart';
import 'package:x_project_flutter/core/repositories/login/login_repository.dart';
import 'package:x_project_flutter/core/repositories/register/register_repository.dart';
import 'package:x_project_flutter/home_screen/home_screen.dart';
import 'package:x_project_flutter/login_screen/login_email_passwd_screen.dart';
import 'package:x_project_flutter/register_screen/chose_email_screen.dart';
import 'package:x_project_flutter/register_screen/chose_password_screen.dart';
import 'core/blocs/login_bloc/login_bloc.dart';
import 'core/repositories/onboarding/firebase_onboarding_data_source.dart';
import 'core/repositories/onboarding/onboarding_repository.dart';
import 'core/repositories/register/firebase_register_data_source.dart';
import 'l10n/generated/app_localizations.dart';
import 'l10n/l10n.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'login_screen/chose_login_screen.dart';
import 'on_board_screen/onboarding_description_screen.dart';
import 'on_board_screen/onboarding_image_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create:
              (context) => LoginBloc(
                loginRepository: LoginRepository(
                  loginDataSource: FirebaseLoginDataSource(),
                ),
              ),
        ),
        BlocProvider<RegisterBloc>(
          create:
              (context) => RegisterBloc(
                registerRepository: RegisterRepository(
                  registerDataSource: FirebaseRegisterDataSource(),
                ),
              ),
        ),
        BlocProvider<OnBoardingBloc>(
          create:
              (context) => OnBoardingBloc(
                onBoardingRepository: OnBoardingRepository(
                  onboardingDataSource: FirebaseOnBoardingDataSource(),
                ),
              ),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: L10n.all,
        theme: ThemeData(
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0028FF),
              foregroundColor: Colors.white,
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
              padding: const EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
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
            displaySmall: TextStyle(fontSize: 14, color: Colors.black),
            labelSmall: TextStyle(
              fontSize: 14,
              color: Colors.blue,
              decoration: TextDecoration.underline, // Apply underline
            ),
          ),
        ),
        routes: {
          Login.routeName: (context) => const Login(),
          LoginEmailPasswdScreen.routeName:
              (context) => const LoginEmailPasswdScreen(),
          ChoseEmailScreen.routeName: (context) => const ChoseEmailScreen(),
          OnboardingDescriptionScreen.routeName:
              (context) => const OnboardingDescriptionScreen(),
          OnboardingImageScreen.routeName:
              (context) => const OnboardingImageScreen(),
          ChosePasswordScreen.routeName:
              (context) => const ChosePasswordScreen(),
          HomeScreen.routeName: (context) => const HomeScreen(),
        },
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/password':
              return MaterialPageRoute(builder: (context) => const Login());

            default:
              return null;
          }
        },
      ),
    );
  }
}
