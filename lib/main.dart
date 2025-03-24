import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants/app_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/course_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/classroom/classroom_screen.dart';
import 'screens/classroom/class_courses_screen.dart';
import 'screens/classroom/course_detail_screen.dart';
import 'screens/live/live_screen.dart';
import 'screens/live/live_player_screen.dart';
import 'screens/quiz/quiz_screen.dart';
import 'screens/quiz/quiz_detail_screen.dart';
import 'screens/quiz/quiz_attempt_screen.dart';
import 'screens/payment/payment_screen.dart';
import 'screens/analytics/analytics_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Wait for Firebase to be initialized
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
    return;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CourseProvider>(
          create: (_) => CourseProvider(),
          update:
              (_, authProvider, previousCourseProvider) =>
                  previousCourseProvider!..update(authProvider.userModel),
        ),
      ],
      child: MaterialApp(
        title: 'LMS App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          scaffoldBackgroundColor: AppColors.backgroundColor,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/home': (context) => const HomeScreen(),
          '/classroom': (context) => const ClassroomScreen(),
          '/live': (context) => const LiveScreen(),
          '/quiz': (context) => const QuizScreen(),
          '/analytics': (context) => const AnalyticsScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/class-courses') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder:
                  (context) => ClassCoursesScreen(
                    classLevel: args['classLevel'],
                    title: args['className'],
                  ),
            );
          } else if (settings.name == '/course-detail') {
            final courseId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => CourseDetailScreen(courseId: courseId),
            );
          } else if (settings.name == '/live-player') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => LivePlayerScreen(lecture: args['lecture']),
            );
          } else if (settings.name == '/quiz-detail') {
            final quizId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => QuizDetailScreen(quizId: quizId),
            );
          } else if (settings.name == '/quiz-attempt') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => QuizAttemptScreen(quiz: args['quiz']),
            );
          } else if (settings.name == '/payment') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder:
                  (context) => PaymentScreen(
                    courseId: args['courseId'],
                    amount: args['amount'],
                  ),
            );
          }
          return null;
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    print("------ AuthWrapper is called --------");

    // Initialize auth state when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authProvider.initializeAuthState();
    });
    print("------authProvider status->>  ${authProvider.status} -------");
    // Show loading indicator while checking auth state
    if (authProvider.status == AuthStatus.authenticating) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Navigate to appropriate screen based on auth state
    if (authProvider.status == AuthStatus.authenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
