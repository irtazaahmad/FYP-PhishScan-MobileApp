import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ScreenSplash extends StatefulWidget {
  const ScreenSplash({Key? key}) : super(key: key);

  @override
  State<ScreenSplash> createState() => _ScreenSplashState();
}

class _ScreenSplashState extends State<ScreenSplash> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Delay to ensure widget is mounted
    Future.delayed(Duration.zero, _checkDeviceAndNavigate);
  }

  Future<void> _checkDeviceAndNavigate() async {
    try {
      if (!mounted) return;

      final deviceId = await _getDeviceId();
      print("my device id is $deviceId");
      final docSnapshot = await _firestore
          .collection('messages')
          .doc(deviceId)
          .get()
          .timeout(const Duration(seconds: 5));

      final startTime = DateTime.now();

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          docSnapshot.exists ? '/getStarted' : '/home',
        );
      }

      final elapsed = DateTime.now().difference(startTime);
      if (elapsed < const Duration(seconds: 2)) {
        await Future.delayed(const Duration(seconds: 200) - elapsed);
      }
    } catch (e) {
      print("error navigation $e");
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/getStarted');
      }
    }
  }

  Future<String> _getDeviceId() async {
    final deviceInfo = await _deviceInfo.deviceInfo;
    return switch (deviceInfo) {
      AndroidDeviceInfo() => deviceInfo.id,
      IosDeviceInfo() => deviceInfo.identifierForVendor ?? 'ios-unknown',
      _ => 'unknown-device',
    };
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9636E2),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: const Text(
                textAlign: TextAlign.center,
                  "Protect Yourself From Phishing Attacks With PhishGuard",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}