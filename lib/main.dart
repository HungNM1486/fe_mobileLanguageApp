import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:language_app/phu_nv/LoginSignup/login_screen.dart';
import 'package:language_app/provider/comment_provider.dart';
import 'package:language_app/provider/exam_provider.dart';
import 'package:language_app/provider/exercise_provider.dart';
import 'package:language_app/provider/language_provider.dart';
import 'package:language_app/provider/like_provider.dart';
import 'package:language_app/provider/notification_provider.dart';
import 'package:language_app/provider/post_provider.dart';
import 'package:language_app/provider/progress_provider.dart';
import 'package:language_app/provider/question_provider.dart';
import 'package:language_app/provider/report_provider.dart';
import 'package:language_app/provider/theme_provider.dart';
import 'package:language_app/provider/auth_provider.dart';
import 'package:language_app/provider/topic_provider.dart';
import 'package:language_app/provider/user_provider.dart';
import 'package:language_app/provider/user_session_provider.dart';
import 'package:language_app/provider/vocabulary_provider.dart';
import 'package:language_app/provider/study_plans_provider.dart';
import 'package:language_app/provider/achievement_provider.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';
import 'package:language_app/service/local_notification_service.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final localNotificationService = LocalNotificationService();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set ErrorWidget.builder outside of the widget tree
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Đã xảy ra lỗi. Vui lòng khởi động lại ứng dụng.',
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  };

  // Request permissions
  // await Permission.microphone.request();
  // await Permission.storage.request();

  // Initialize notifications
  if (!kIsWeb) {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'welcome_channel',
        'Welcome Notifications',
        channelDescription: 'Notifications when app starts',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        0,
        'Chào mừng đến Language App',
        'Bắt đầu học ngoại ngữ ngay hôm nay!',
        notificationDetails,
      );
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
        ChangeNotifierProvider(create: (_) => TopicProvider()),
        ChangeNotifierProvider(create: (_) => VocabularyProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => LikeProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => StudyPlansProvider()),
        ChangeNotifierProvider(create: (_) => UserSessionProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ExamProvider>(
          create: (context) => ExamProvider(
            baseUrl: UrlUtils.getBaseUrl(),
            authProvider: Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, authProvider, previous) => ExamProvider(
            baseUrl: UrlUtils.getBaseUrl(),
            authProvider: authProvider,
          ),
        ),
        ChangeNotifierProvider(create: (_) => QuestionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Add app lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Check user session on app start
    _checkUserSession();
  }

  @override
  void dispose() {
    // Remove app lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle app lifecycle state changes
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App going to background
      _handleAppBackground();
    } else if (state == AppLifecycleState.resumed) {
      // App coming to foreground
      _handleAppForeground();
    }
  }

  // Check if user is logged in and has an active session
  Future<void> _checkUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      // User is logged in, check for active session
      try {
        final userSessionProvider = Provider.of<UserSessionProvider>(
          context,
          listen: false,
        );
        await userSessionProvider.checkAndManageSession();
      } catch (e) {
        debugPrint('Error checking user session: $e');
      }
    }
  }

  // Handle app going to background
  Future<void> _handleAppBackground() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      // User is logged in, save current timestamp
      await prefs.setString(
        'background_time',
        DateTime.now().toIso8601String(),
      );
    }
  }

  // Handle app coming to foreground
  Future<void> _handleAppForeground() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      final backgroundTimeStr = prefs.getString('background_time');

      if (backgroundTimeStr != null) {
        // Calculate how long the app was in background
        final backgroundTime = DateTime.parse(backgroundTimeStr);
        final now = DateTime.now();
        final difference = now.difference(backgroundTime);

        // If app was in background for more than 30 minutes, close current session and create new one
        if (difference.inMinutes > 30) {
          try {
            final userSessionProvider = Provider.of<UserSessionProvider>(
              context,
              listen: false,
            );
            final currentSessionId = prefs.getInt('current_session_id');

            if (currentSessionId != null) {
              // End previous session
              await userSessionProvider.updateLogoutTime(currentSessionId);
              // Start new session
              await userSessionProvider.createSession();
            }
          } catch (e) {
            debugPrint('Error managing sessions: $e');
          }
        }

        // Clear background time
        await prefs.remove('background_time');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Language App',
          navigatorKey: navigatorKey,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.themeMode,
          home: const CustomSplashScreen(),
        );
      },
    );
  }
}

// Custom Splash Screen Widget
class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({super.key});

  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Khởi tạo animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Thiết lập các hiệu ứng
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuad),
    );

    // Bắt đầu animation
    _animationController.forward();

    // Chuyển màn hình sau 3 giây
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Check if the widget is still in the tree
        _checkLoginAndRedirect();
      }
    });
  }

  void _checkLoginAndRedirect() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      // User is logged in, check if their session is valid
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isValid = await authProvider.checkAuthStatus();

      if (isValid) {
        // Valid session, navigate to home page
        // Note: Replace with your actual home page route
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Loginscreen()),
        );
      } else {
        // Invalid session, navigate to login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Loginscreen()),
        );
      }
    } else {
      // No token, navigate to login
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const Loginscreen()));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      key: UniqueKey(), // Add unique key to prevent widget tree conflicts
      // Màu nền splash
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.intro2),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo với hiệu ứng fade + slide
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Image.asset(
                    AppImages.imgbook,
                    width: 200 * pix,
                    height: 200 * pix,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Text với hiệu ứng fade
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Language App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32 * pix,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'BeVietnamPro',
                  ),
                ),
              ),

              SizedBox(height: 30 * pix),

              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),

              SizedBox(height: 20 * pix),

              // Text loading
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Đang tải ứng dụng...',
                  style: TextStyle(color: Colors.white, fontSize: 16 * pix),
                ),
              ),
              SizedBox(height: 30 * pix),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Kiến thức là sức mạnh, hành động là chìa khóa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14 * pix,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'BeVietnamPro',
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Phát triển mỗi ngày, hoàn thiện mỗi giờ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14 * pix,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'BeVietnamPro',
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
