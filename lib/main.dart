import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phishscan/components/Analysis.dart';
import 'package:phishscan/components/HomeScreen.dart';
import 'package:phishscan/components/message_screen.dart';
import 'package:phishscan/components/settings.dart';
import 'package:phishscan/components/screen_splash.dart';
import 'components/splash_screen.dart';
import 'controller/sms_message_model.dart';

import 'firebase_options.dart';


final notificationPermissionProvider = StateProvider<bool>((ref) => false);


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> requestNotificationPermission(WidgetRef ref) async {
  var status = await Permission.notification.status;

  if (status.isDenied || status.isRestricted || status.isLimited) {
    status = await Permission.notification.request();
  }

  if (status.isGranted) {
    ref
        .read(notificationPermissionProvider.notifier)
        .state = true;
  }
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(SMSMessageAdapter()); // Register adapter if required
  await Hive.openBox<SMSMessage>('sms_cache');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);


  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future.microtask(() => requestNotificationPermission(ref));


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "PhishScan",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7E30E1)),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SafeAppWrapper(child: ScreenSplash()),
        '/getStarted': (context) => const SplashScreen(),
        '/editor': (context) => const MessageAnalysisPage(),
        '/home': (context) => const HomeScreen(),
        '/messages': (context) => MessageScreen(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}

class SafeAppWrapper extends StatelessWidget {
  final Widget child;

  const SafeAppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 500)),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("App Error: ${snapshot.error}");
          return const ErrorScreen();
        }
        return child;
      },
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              "Something went wrong!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () => runApp(const ProviderScope(child: MyApp())),
              child: const Text(
                "Restart App",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
