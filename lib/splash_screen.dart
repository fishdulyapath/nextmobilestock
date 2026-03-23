import 'package:flutter/material.dart';
import 'package:mobilestock/global.dart' as global;
import 'package:mobilestock/model/permission_model.dart';
import 'package:mobilestock/repository/webservice_repository.dart';

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
    // main() โหลด initializeConfig() แล้ว ไม่ต้องโหลดซ้ำ
    // รอแค่ 1 frame ให้ widget build เสร็จก่อน navigate
    await Future.delayed(const Duration(milliseconds: 300));

    await _checkLogin();
  }

  Future<void> _checkLogin() async {
    final isLoggedIn = global.userCode.isNotEmpty && global.userName.isNotEmpty && global.serverDatabase.isNotEmpty && global.serverProvider.isNotEmpty && global.branchCode.isNotEmpty;

    if (!isLoggedIn) {
      if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      return;
    }

    // ดึงสิทธิ์ user ก่อน navigate (กรณี refresh หน้า web)
    await WebServiceRepository().getUserPermissionLogin(global.userCode).then((value) {
      if (value.success) {
        final list = value.data as List;
        if (list.isNotEmpty) {
          global.setPermissions(PermissionModel.fromJson(list.first));
        }
      }
    }).catchError((_) {});

    // อ่าน URL ปัจจุบันเพื่อ restore หน้าเดิมบน web
    final fragment = Uri.base.fragment;
    final validRoutes = {
      '/menu',
      '/cartlist',
      '/stockdetail',
      '/requestcartlist',
      '/transfercartlist',
      '/handheldcartlist',
      '/barcodemanage',
      '/permission',
    };
    final target = validRoutes.contains(fragment) ? fragment : '/menu';

    // ตรวจสอบสิทธิ์ของ route ที่ต้องการเข้า
    final routePermMap = {
      '/cartlist': global.permStockList,
      '/requestcartlist': global.permRequestList,
      '/transfercartlist': global.permTransferList,
      '/handheldcartlist': global.permHandheldList,
      '/barcodemanage': global.permBarcodeList,
      '/stockdetail': global.permInfoList,
      '/permission': global.isSuperAdmin || global.permPermissionList,
    };
    final hasPermission = routePermMap[target] ?? true;
    final finalTarget = hasPermission ? target : '/menu';

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(finalTarget, (route) => false);
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
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
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
