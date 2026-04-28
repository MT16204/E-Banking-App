import 'package:banking_app/core/config/app_config.dart';
import 'package:banking_app/data/repositories/auth_repository.dart';
import 'package:banking_app/data/repositories/cards_repository.dart';
import 'package:banking_app/data/repositories/current_user_repository.dart';
import 'package:banking_app/data/repositories/notification_repository.dart';
import 'package:banking_app/data/repositories/transfer_repository.dart';
import 'package:banking_app/data/repositories/transactions_repository.dart';
import 'package:banking_app/data/repositories/wallet_repository.dart';
import 'package:banking_app/data/services/auth_services.dart';
import 'package:banking_app/features/analytics/screens/analytics_screen.dart';
import 'package:banking_app/features/auth/screens/create_password_screen.dart';
import 'package:banking_app/features/auth/screens/forgor_password_screen.dart';
import 'package:banking_app/features/auth/screens/login_screen.dart';
import 'package:banking_app/features/auth/screens/otp_screen.dart';
import 'package:banking_app/features/auth/screens/reset_password_screen.dart';
import 'package:banking_app/features/auth/screens/signup_screen.dart';
import 'package:banking_app/features/auth/screens/signup_success_screen.dart';
import 'package:banking_app/features/auth/screens/splash_screen.dart';
import 'package:banking_app/features/auth/screens/verify_screen.dart';
import 'package:banking_app/features/cards/screens/card_screen.dart';
import 'package:banking_app/features/home/screens/home_screen.dart';
import 'package:banking_app/features/notifications/screens/notification_screen.dart';
import 'package:banking_app/features/payments/screens/qr_payment_screen.dart';
import 'package:banking_app/features/payments/screens/transaction_screen.dart';
import 'package:banking_app/features/profile/screens/background_picker.dart';
import 'package:banking_app/features/profile/screens/change_password_screen.dart';
import 'package:banking_app/features/profile/screens/profile_screen.dart';
import 'package:banking_app/features/security/screens/smart_otp_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appwrite/appwrite.dart';
import 'package:provider/provider.dart';
import 'package:banking_app/providers/language_provider.dart';
import 'package:banking_app/providers/user_provider.dart';
import 'package:banking_app/providers/appearance_provider.dart';
import 'package:banking_app/features/analytics/bloc/analytics_bloc.dart';
import 'package:banking_app/features/analytics/bloc/analytics_event.dart';
import 'package:banking_app/features/auth/bloc/auth_bloc.dart';
import 'package:banking_app/features/auth/bloc/auth_event.dart';
import 'package:banking_app/features/cards/bloc/cards_bloc.dart';
import 'package:banking_app/features/cards/bloc/cards_event.dart';
import 'package:banking_app/features/home/bloc/home_bloc.dart';
import 'package:banking_app/features/home/bloc/home_event.dart';
import 'package:banking_app/features/notifications/bloc/notifications_bloc.dart';
import 'package:banking_app/features/notifications/bloc/notifications_event.dart';
import 'package:banking_app/features/payments/bloc/payments_bloc.dart';
import 'package:banking_app/features/payments/bloc/payments_event.dart';
import 'package:banking_app/features/profile/bloc/profile_bloc.dart';
import 'package:banking_app/features/profile/bloc/profile_event.dart';

late Client client;
late Account account;
late AuthService authService;
late AuthRepository authRepository;
late CurrentUserRepository currentUserRepository;
late WalletRepository walletRepository;
late NotificationRepository notificationRepository;
late TransferRepository transferRepository;
late TransactionsRepository transactionsRepository;
late CardsRepository cardsRepository;
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

  AppConfig.validate();

  client = Client()
      .setEndpoint(AppConfig.appwriteEndpoint)
      .setProject(AppConfig.appwriteProjectId);

  account = Account(client);
  databases = Databases(client);
  authService = AuthService(account);
  currentUserRepository = CurrentUserRepository(account);
  walletRepository = WalletRepository(databases);
  notificationRepository = NotificationRepository(databases);
  transferRepository = TransferRepository(databases, notificationRepository);
  transactionsRepository = TransactionsRepository(databases);
  cardsRepository = CardsRepository(databases);
  authRepository = AuthRepository(authService, databases);
  languageProvider = LanguageProvider();
  await languageProvider.load();

  final appearanceProvider = AppearanceProvider();

  final userProvider = UserProvider()
    ..setAppearanceProvider(appearanceProvider)
    ..setCurrentUserRepository(currentUserRepository)
    ..setWalletRepository(walletRepository)
    ..setTransactionsRepository(transactionsRepository)
    ..setCardsRepository(cardsRepository)
    ..setNotificationRepository(notificationRepository);

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
        Provider<CurrentUserRepository>.value(value: currentUserRepository),
        Provider<WalletRepository>.value(value: walletRepository),
        Provider<NotificationRepository>.value(value: notificationRepository),
        Provider<TransferRepository>.value(value: transferRepository),
        Provider<TransactionsRepository>.value(value: transactionsRepository),
        Provider<CardsRepository>.value(value: cardsRepository),
        ChangeNotifierProvider<LanguageProvider>.value(value: languageProvider),
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
        ChangeNotifierProvider<AppearanceProvider>.value(
          value: appearanceProvider,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthBloc(
              authRepository: authRepository,
              currentUserRepository: currentUserRepository,
            )..add(const AuthStarted()),
          ),
          BlocProvider(
            create: (_) => HomeBloc(
              currentUserRepository: currentUserRepository,
              walletRepository: walletRepository,
              transactionsRepository: transactionsRepository,
              cardsRepository: cardsRepository,
            )..add(const HomeStarted()),
          ),
          BlocProvider(
            create: (_) => AnalyticsBloc(
              currentUserRepository: currentUserRepository,
              transactionsRepository: transactionsRepository,
            )..add(const AnalyticsStarted()),
          ),
          BlocProvider(
            create: (_) => CardsBloc(
              currentUserRepository: currentUserRepository,
              cardsRepository: cardsRepository,
            )..add(const CardsStarted()),
          ),
          BlocProvider(
            create: (_) => NotificationsBloc(
              currentUserRepository: currentUserRepository,
              notificationRepository: notificationRepository,
            )..add(const NotificationsStarted()),
          ),
          BlocProvider(
            create: (_) => PaymentsBloc(
              currentUserRepository: currentUserRepository,
              walletRepository: walletRepository,
              transactionsRepository: transactionsRepository,
              transferRepository: transferRepository,
            )..add(const PaymentsStarted()),
          ),
          BlocProvider(
            create: (_) => ProfileBloc(
              authRepository: authRepository,
              currentUserRepository: currentUserRepository,
              walletRepository: walletRepository,
            )..add(const ProfileStarted()),
          ),
        ],
        child: MyApp(initialRoute: startRoute, isLoggedIn: isLoggedIn),
      ),
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
