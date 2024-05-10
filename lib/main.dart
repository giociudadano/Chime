library main;

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Imports external widgets.
import 'package:choice/choice.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

// Imports Firebase libraries. Responsible for authentication and reading and writing to database.
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Imports service libraries. Responsible for one-time authentication methods.
import 'package:google_sign_in/google_sign_in.dart';

// Imports cosmetic and accessibility libraries. Responsible for dynamic theme modes and languages.
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Imports helper functions and models.
import 'models/material_colors_model.dart';
import 'models/chime_colors_model.dart';
import 'models/string_extension.dart';
part 'models/product_model.dart';

// Defines all page components.
part 'pages/onboarding.dart';
part 'pages/login.dart';
part 'pages/signup.dart';
part 'pages/home.dart';

// Buying
part 'pages/buy/products.dart';
part 'pages/buy/products_more.dart';
part 'pages/buy/places.dart';
part 'pages/buy/places_more.dart';
part 'pages/buy/places_more_categories.dart';
part 'pages/buy/cart.dart';
part 'pages/buy/checkout.dart';
part 'pages/buy/checkout_addresses.dart';
part 'pages/buy/checkout_success.dart';
part 'pages/buy/orders.dart';
part 'pages/buy/orders_more.dart';

// Selling
part 'pages/sell/store.dart';
part 'pages/sell/store_add.dart';
part 'pages/sell/store_edit.dart';
part 'pages/sell/products.dart';
part 'pages/sell/products_add.dart';
part 'pages/sell/products_edit.dart';
part 'pages/sell/products_variants.dart';
part 'pages/sell/categories.dart';
part 'pages/sell/categories_products.dart';
part 'pages/sell/orders.dart';

// Imports all services and objects.
part 'services/auth_service.dart';
part 'objects/product_card.dart';
part 'objects/product_card_editable.dart';
part 'objects/place_card.dart';
part 'objects/cart_card.dart';
part 'objects/cart_item_card.dart';
part 'objects/order_card.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    webProvider:
        ReCaptchaV3Provider('6LcrkeAoAAAAALc0LRdA241kDnyG5S8ySSjx26PS'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  // ignore: library_private_types_in_public_api
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  // Loads the currently selected theme. If no theme is selected, defaults to the system theme.
  void loadTheme() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    String? theme = sharedPreferences.getString('theme');
    if (theme == 'light') {
      changeTheme(ThemeMode.light);
    } else if (theme == 'dark') {
      changeTheme(ThemeMode.dark);
    }
  }

  // Changes the current theme based on the passed ThemeMode object.
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Special Problem',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF466800),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF466800),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('tl', 'PH'),
      ],
      home: const MyHomePage(),
      navigatorKey: navigatorKey,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var isOnboardingVisited = false;
  String appMode = 'Buy';

  @override
  void initState() {
    super.initState();
    loadIsOnboardingVisited();
    addLoginStateListener();
  }

  // Checks if the user is new. Visits OnBoardingPage if so and LoginPage if not.
  void loadIsOnboardingVisited() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    setState(() {
      isOnboardingVisited =
          sharedPreferences.getBool('isOnboardingVisited') ?? false;
    });
  }

  void addLoginStateListener() async {
    Stream<User?> loginStateListener = FirebaseAuth.instance.authStateChanges();
    loginStateListener.listen((User? user) async {
      if (user != null) {
        Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: isOnboardingVisited ? const LoginPage() : const OnBoardingPage(),
    );
  }
}
