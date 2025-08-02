
import 'package:authtest/chart.dart';
import 'package:authtest/doctor.dart';
import 'package:authtest/l10n/l10n.dart';
import 'package:authtest/langconsts.dart';
import 'package:authtest/roles.dart';
import 'package:authtest/services/aw_noti.dart';
import 'package:authtest/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:authtest/assistant.dart';
import 'package:authtest/elder.dart';
import 'package:authtest/services/notifi_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'register.dart';
import 'l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:authtest/langconsts.dart';
import 'package:authtest/langpage.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  tz.initializeTimeZones();
  await NotificationService.initializeNotification();
  // WidgetsFlutterBinding.ensureInitialized();  
  NotificationManager().initNotification();
  
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  _MyAppState createState() => _MyAppState();
    static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');
    void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }
  var auth = FirebaseAuth.instance;
  var isLogin = false;
  var userrool = '';
  
  checkIfLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String rool = prefs.getString('rool') ?? '';

    if (isLoggedIn) {
      setState(() {
        isLogin = true;
        userrool = rool;
      });
    }

    auth.authStateChanges().listen((User? user) async {
      if (user != null && mounted) {
        setState(() {
          isLogin = true;
        });

        // Retrieve the user's rool from Firebase Firestore
        DocumentSnapshot documentSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (documentSnapshot.exists) {
          String rool = documentSnapshot['rool'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', true);
          prefs.setString('rool', rool);

          setState(() {
            userrool = rool;
          });
        }
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', false);
        prefs.setString('rool', '');
      }
    });


  }

  @override
  void initState() {
    checkIfLogin();
    super.initState();
  }
    @override
  void didChangeDependencies() {
    getLocale().then((locale) => {setLocale(locale)});
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    Widget defaultPage = LanguagePage();

    // Check the user's rool and route them to the appropriate page
    if (isLogin && userrool == 'elder') {
      defaultPage = ElderPage();
    } else if (isLogin && userrool == 'assistant') {
      defaultPage = AssistantPage();
    } else if (isLogin && userrool == 'doctor') {
      defaultPage = DoctorPage();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
       navigatorKey: MyApp.navigatorKey,
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 188, 213, 250),
        elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
              primary:Color.fromRGBO(43, 52, 103, 0.8),
          )),
      ),
      supportedLocales: L10n.all,
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: defaultPage,
    );
  }
}