import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mobilestock/core/client.dart';
import 'package:mobilestock/model/user_login_model.dart';
import 'package:mobilestock/global.dart' as global;

class AuthRepository {
  Future<ApiResponse> authenUser(String username, String password, String provider, String dbname) async {
    try {
      global.loadConfig();
      Dio client = Client().init();
      UserLoginModel user = UserLoginModel(
        databasename: dbname,
        provider: provider,
        user: username,
        pass: password,
      );
      final response = await client.get('/authentication?provider_name=$provider&database_name=$dbname&user_code=$username&password=$password');
      final rawData = json.decode(response.toString());
      if (rawData['error'] != null) {
        throw Exception('${rawData['code']}: ${rawData['message']}');
      }
      if (rawData['success'] == true) {
        return ApiResponse.fromMap({
          'success': true,
          'data': "",
        });
      } else {
        // success = false หมายถึงไม่พบข้อมูลผู้ใช้
        throw Exception('ไม่พบข้อมูลผู้ใช้ หรือรหัสผ่านไม่ถูกต้อง');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.message.toString());
      } else {
        throw Exception(e.error);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
