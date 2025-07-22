import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:x_project_flutter/core/blocs/on_boarding_bloc/on_boarding_bloc.dart';
import 'package:x_project_flutter/core/blocs/register_bloc/register_bloc.dart';
import 'package:x_project_flutter/core/blocs/user_data_bloc/user_data_bloc.dart';
import 'package:x_project_flutter/core/repositories/login/firebase_login_data_source.dart';
import 'package:x_project_flutter/core/repositories/login/login_repository.dart';
import 'package:x_project_flutter/core/repositories/register/register_repository.dart';
import 'package:x_project_flutter/core/repositories/user_data/firebase_user_data_source.dart';
import 'package:x_project_flutter/core/repositories/user_data/user_repository.dart';
import 'package:x_project_flutter/login_screen/login_email_passwd_screen.dart';
import 'package:x_project_flutter/profile_screen/change_picture_screen.dart';
import 'package:x_project_flutter/profile_screen/profile_screen.dart';
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
import 'main_screen.dart';
import 'package:x_project_flutter/core/blocs/tweet_bloc/tweet_bloc.dart';
import 'package:x_project_flutter/core/blocs/tweet_bloc/tweet_event.dart';
import 'package:x_project_flutter/core/repositories/tweet/firebase_tweet_data_source.dart';
import 'package:x_project_flutter/core/repositories/tweet/tweet_repository.dart';
import 'package:x_project_flutter/screens/tweet_detail_screen.dart';
import 'package:x_project_flutter/screens/profile_screen.dart' as view_profile;
import 'package:x_project_flutter/screens/conversation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => UserRepository(userDataSource: FirebaseUserDataSource()),
        ),
        RepositoryProvider(
          create: (_) => TweetRepository(tweetDataSource: FirebaseTweetDataSource()),
        ),
      ],
      child: MultiBlocProvider(
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
          BlocProvider<UserDataBloc>(
            create:
                (context) => UserDataBloc(
                  userRepository: UserRepository(
                    userDataSource: FirebaseUserDataSource(),
                  ),
                ),
          ),
          BlocProvider<TweetBloc>(
            create: (context) => TweetBloc(
              tweetRepository: TweetRepository(tweetDataSource: FirebaseTweetDataSource()),
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
          debugShowCheckedModeBanner: false,
          supportedLocales: L10n.all,
          theme: ThemeData(
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0028FF),
                foregroundColor: Colors.white,
                textStyle: TextStyle(color: Colors.white, fontSize: 13),
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
            ProfileScreen.routeName: (context) => const ProfileScreen(),
            ProfileChangeImageScreen.routeName:
                (context) => const ProfileChangeImageScreen(),
            MainScreen.routeName: (context) => const MainScreen(),
          },
          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {
              case '/password':
                return MaterialPageRoute(builder: (context) => const Login());
              case TweetDetailScreen.routeName:
                final args = settings.arguments as Map<String, String>;
                return MaterialPageRoute(
                  builder: (context) => MultiRepositoryProvider(
                    providers: [
                      RepositoryProvider(create: (_) => TweetRepository(tweetDataSource: FirebaseTweetDataSource())),
                      RepositoryProvider(create: (_) => UserRepository(userDataSource: FirebaseUserDataSource())),
                    ],
                    child: BlocProvider(
                      create: (context) => TweetBloc(
                        tweetRepository: RepositoryProvider.of<TweetRepository>(context),
                      )..add(FetchTweets()),
                      child: TweetDetailScreen(
                        tweetId: args['tweetId']!,
                        authorId: args['authorId']!,
                      ),
                    ),
                  ),
                );
              case view_profile.ProfileScreen.routeName:
                final args = settings.arguments as Map<String, String>;
                return MaterialPageRoute(
                  builder: (context) => view_profile.ProfileScreen(userId: args['userId']!),
                );
              case ConversationScreen.routeName:
                final args = settings.arguments as Map<String, String>;
                return MaterialPageRoute(
                  builder: (context) => ConversationScreen(
                    conversationId: args['conversationId']!,
                    otherUserId: args['otherUserId']!,
                  ),
                );
              default:
                return null;
            }
          },
        ),
      ),
    );
  }
}

