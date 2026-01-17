import 'package:flutter/material.dart';
import 'package:mobilestock/global.dart' as global;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // โหลดค่า config จาก SharedPreferences
    await global.loadConfigFromPrefs();

    // รอ 2 วินาทีแสดง splash
    await Future.delayed(const Duration(seconds: 2));

    _checkLogin();
  }

  void _checkLogin() {
    // เช็คว่ามีข้อมูล user และ config ครบหรือไม่
    if (global.userCode.isNotEmpty && global.userName.isNotEmpty && global.serverDatabase.isNotEmpty && global.serverProvider.isNotEmpty && global.branchCode.isNotEmpty) {
      Navigator.of(context).pushNamedAndRemoveUntil('/menu', (route) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/logo/logonextstep.png',
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Stock Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ระบบจัดการสต็อกสินค้า',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
