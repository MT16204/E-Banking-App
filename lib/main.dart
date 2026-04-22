import 'package:banking_app/config/app_config.dart';
import 'package:banking_app/data/repositories/auth_repository.dart';
import 'package:banking_app/data/services/auth_services.dart';
import 'package:banking_app/screens/analytics_screen.dart';
import 'package:banking_app/screens/auth/create_password_screen.dart';
import 'package:banking_app/screens/auth/forgor_password_screen.dart';
import 'package:banking_app/screens/auth/otp_screen.dart';
import 'package:banking_app/screens/auth/reset_password_screen.dart';
import 'package:banking_app/screens/auth/signup_screen.dart';
import 'package:banking_app/screens/auth/verify_screen.dart';
import 'package:banking_app/screens/background_picker.dart';
import 'package:banking_app/screens/change_password_screen.dart';
import 'package:banking_app/screens/notification_screen.dart';
import 'package:banking_app/screens/splash_screen.dart';
import 'package:banking_app/screens/transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appwrite/appwrite.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth/signup_success_screen.dart';
import 'screens/profile_screen.dart';
import 'package:banking_app/providers/language_provider.dart';
import 'package:banking_app/providers/user_provider.dart';
import 'package:banking_app/providers/appearance_provider.dart';
import 'package:banking_app/screens/qr_payment_screen.dart';
import 'package:banking_app/screens/card_screen.dart';
import 'package:banking_app/screens/smart_otp_screen.dart';

late Client client;
late Account account;
late AuthService authService;
late AuthRepository authRepository;
late Databases databases;
late LanguageProvider languageProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.validate();

  print("DEBUG_ENDPOINT: '${AppConfig.appwriteEndpoint}'");
  print("DEBUG_PROJECT: '${AppConfig.appwriteProjectId}'");
  

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // ✅ Kiểm tra ngay — crash rõ ràng nếu quên truyền --dart-define
  AppConfig.validate();

  client = Client()
      .setEndpoint(AppConfig.appwriteEndpoint)
      .setProject(AppConfig.appwriteProjectId);

  account = Account(client);
  databases = Databases(client);
  authService = AuthService(account);
  authRepository = AuthRepository(authService, databases);
  languageProvider = LanguageProvider();
  await languageProvider.load();

  final appearanceProvider = AppearanceProvider();

  final userProvider = UserProvider()
    ..setAppearanceProvider(appearanceProvider);

  String startRoute = '/login';
  bool isLoggedIn = false;

  try {
    final user = await account.get();
    startRoute = '/home';
    isLoggedIn = true;
    await appearanceProvider.loadForUser(user.$id);
  } catch (e) {
    await appearanceProvider.load();
    startRoute = '/login';
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        ChangeNotifierProvider<LanguageProvider>.value(value: languageProvider),
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
        ChangeNotifierProvider<AppearanceProvider>.value(
          value: appearanceProvider,
        ),
      ],
      child: MyApp(initialRoute: startRoute, isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.initialRoute,
    required this.isLoggedIn,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    if (widget.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<UserProvider>().fetchUser(account);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appearance = context.watch<AppearanceProvider>();

    final isDark = appearance.currentTheme.isDark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );

    return MaterialApp(
      title: 'Nova - Banking',
      debugShowCheckedModeBanner: false,
      theme: appearance.themeData.copyWith(
        textTheme: GoogleFonts.montserratTextTheme(
          appearance.themeData.textTheme,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/otp-verify': (context) => const OTPScreen(),
        '/create-password': (context) => const CreatePasswordScreen(),
        '/signup-success': (context) => const SignupSuccessScreen(),
        '/transaction_screen': (context) => const TransactionScreen(),
        '/notification_screen': (context) => const NotificationScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
        '/card': (context) => const CardScreen(),
        '/smart_otp': (context) => const SmartOtpScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-verify-otp': (context) => const VerifyScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/background-picker': (context) => const BackgroundPickerScreen(),
        '/qr_payment': (context) {
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          final userId = userProvider.user?.$id ?? '';
          return QRPaymentScreen(client: client, currentUserId: userId);
        },
      },
    );
  }
}
