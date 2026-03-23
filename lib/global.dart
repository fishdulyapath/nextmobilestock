import 'package:get_storage/get_storage.dart';
import 'package:mobilestock/model/permission_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

late GetStorage appStorage;
SharedPreferences? _prefs;

String serverHost = "";
String serverProvider = "";
String serverDatabase = "";
String userCode = "";
String userName = "";
String branchCode = "";
String branchName = "";

// Permissions
bool permStockList = false;
bool permRequestList = false;
bool permTransferList = false;
bool permHandheldList = false;
bool permBarcodeList = false;
bool permInfoList = false;
bool permPermissionList = false;

bool get isSuperAdmin => userCode.toLowerCase() == 'superadmin';

void setPermissions(PermissionModel perm) {
  if (isSuperAdmin) {
    permStockList = true;
    permRequestList = true;
    permTransferList = true;
    permHandheldList = true;
    permBarcodeList = true;
    permInfoList = true;
    permPermissionList = true;
  } else {
    permStockList = perm.stockList;
    permRequestList = perm.requestList;
    permTransferList = perm.transferList;
    permHandheldList = perm.handheldList;
    permBarcodeList = perm.barcodeList;
    permInfoList = perm.infoList;
    permPermissionList = perm.permissionList;
  }
}

// ดึง SharedPreferences instance (lazy initialization)
Future<SharedPreferences> _getPrefs() async {
  _prefs ??= await SharedPreferences.getInstance();
  return _prefs!;
}

Future<void> initializeConfig() async {
  await GetStorage.init("AppConfig");
  appStorage = GetStorage("AppConfig");
  _prefs = await SharedPreferences.getInstance();
  await loadConfigFromPrefs();
}

// โหลดค่า config จาก SharedPreferences
Future<void> loadConfigFromPrefs() async {
  final prefs = await _getPrefs();
  serverHost = prefs.getString("host") ?? "";
  serverProvider = prefs.getString("provider") ?? "";
  serverDatabase = prefs.getString("dbname") ?? "";
  userCode = prefs.getString("usercode") ?? "";
  userName = prefs.getString("username") ?? "";
  branchCode = prefs.getString("branchcode") ?? "";
  branchName = prefs.getString("branchname") ?? "";
}

// บันทึกค่า config ลง SharedPreferences
Future<void> saveConfigToPrefs({
  String? host,
  String? provider,
  String? dbname,
  String? usercode,
  String? username,
  String? branchcode,
  String? branchname,
}) async {
  final prefs = await _getPrefs();
  if (host != null) {
    await prefs.setString("host", host);
    serverHost = host;
  }
  if (provider != null) {
    await prefs.setString("provider", provider);
    serverProvider = provider;
  }
  if (dbname != null) {
    await prefs.setString("dbname", dbname);
    serverDatabase = dbname;
  }
  if (usercode != null) {
    await prefs.setString("usercode", usercode);
    userCode = usercode;
  }
  if (username != null) {
    await prefs.setString("username", username);
    userName = username;
  }
  if (branchcode != null) {
    await prefs.setString("branchcode", branchcode);
    branchCode = branchcode;
  }
  if (branchname != null) {
    await prefs.setString("branchname", branchname);
    branchName = branchname;
  }
}

// ล้างค่า user (สำหรับ logout)
Future<void> clearUserData() async {
  final prefs = await _getPrefs();
  await prefs.remove("usercode");
  await prefs.remove("username");
  await prefs.remove("branchcode");
  await prefs.remove("branchname");
  userCode = "";
  userName = "";
  branchCode = "";
  branchName = "";
}

// เก็บไว้เพื่อ backward compatibility กับโค้ดเดิม
Future<void> loadConfig() async {
  await loadConfigFromPrefs();
}
