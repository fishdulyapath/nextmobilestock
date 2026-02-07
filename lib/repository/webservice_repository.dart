import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';

import 'package:mobilestock/core/client.dart';
import 'package:mobilestock/model/cart_model.dart';
import 'package:mobilestock/model/item_model.dart';
import 'package:mobilestock/model/post_select_model.dart';
import 'package:mobilestock/model/user_login_model.dart';
import 'package:mobilestock/global.dart' as global;
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';

class WebServiceRepository {
  Future<ApiResponse> getLocation(String whcode) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.get('/getLocation?provider=${global.serverProvider}&dbname=${global.serverDatabase}&whcode=$whcode');
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> getSupplier(search) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.get('/getSupplier?provider=${global.serverProvider}&dbname=${global.serverDatabase}&branchcode=${global.branchCode}&search=$search');
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> getWarehouse() async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.get('/getWarehouse?provider=${global.serverProvider}&dbname=${global.serverDatabase}&branchcode=${global.branchCode}');
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> getCartList(transflag) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.get('/getCartList?provider=${global.serverProvider}&dbname=${global.serverDatabase}&branchcode=${global.branchCode}&transflag=$transflag');
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> getCartSubList() async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.get('/getCartSubList?provider=${global.serverProvider}&dbname=${global.serverDatabase}&branchcode=${global.branchCode}');
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> getBranchList() async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.get('/getBranchList?provider=${global.serverProvider}&dbname=${global.serverDatabase}');
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> getItemSearch(String search) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.get('/getItemSearch?provider=${global.serverProvider}&dbname=${global.serverDatabase}&search=$search');
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> getItemDetail(String barcode, String whcode, String lccode) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.get('/getItemDetail?provider=${global.serverProvider}&dbname=${global.serverDatabase}&barcode=$barcode&whcode=$whcode&lccode=$lccode');
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> getCartDetail(String docno) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.get('/getCartDetail?provider=${global.serverProvider}&dbname=${global.serverDatabase}&docno=$docno');
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> getCartSubDetail(String docno) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.get('/getCartSubDetail?provider=${global.serverProvider}&dbname=${global.serverDatabase}&docno=$docno');
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> saveCartDoc(CartModel cart) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      // ดึงรายละเอียดสินค้าในตะกร้า
      final cartDetailResponse = await getCartDetail(cart.docno);
      if (!cartDetailResponse.success) {
        throw Exception('ไม่สามารถดึงรายละเอียดตะกร้าได้');
      }

      final cartDetails = (cartDetailResponse.data as List).map((data) => CartDetailModel.fromJson(data)).toList();

      // สร้าง docref: MTFyyyymmddhhmm-#### (random 4 ตัว)
      final now = DateTime.now();
      final random = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
      final docref = 'MSC${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}-$random'; // สร้าง payload
      final payload = {
        'docno': cart.docno,
        'docref': docref,
        'branchcode': global.branchCode, 'whcode': cart.whcode,
        'locationcode': cart.locationcode,
        'remark': cart.remark,
        'usercode': global.userCode,
        'docdate': cart.docdate,
        'doctime': cart.doctime.length >= 5 ? cart.doctime.substring(0, 5) : cart.doctime, // เอาแค่ HH:mm
        'details': cartDetails.map((detail) {
          return {
            'item_code': detail.itemcode,
            'item_name': detail.itemname,
            'unit_code': detail.unitcode,
            'qty': detail.qty.toString(),
            'location': detail.locationcode,
          };
        }).toList(),
      };
      final response = await client.post(
        '/approveSaveStock?provider=${global.serverProvider}&dbname=${global.serverDatabase}&docno=${cart.docno}',
        data: payload,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      final rawData = json.decode(response.toString());

      // ตรวจสอบ response format ใหม่
      if (rawData['success'] == true) {
        // สำเร็จ - ใช้ docref จาก response หรือที่ gen ขึ้นมา
        return ApiResponse(
          success: true,
          message: '',
          data: {'docref': rawData['docref'] ?? docref},
        );
      } else {
        // error - return error message
        return ApiResponse(
          success: false,
          message: rawData['error'] ?? 'เกิดข้อผิดพลาดในการบันทึก',
          data: null,
        );
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> approveSaveHandHeld(CartModel cart) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      // ดึงรายละเอียดสินค้าในตะกร้า
      final cartDetailResponse = await getCartDetail(cart.docno);
      if (!cartDetailResponse.success) {
        throw Exception('ไม่สามารถดึงรายละเอียดตะกร้าได้');
      }

      final cartDetails = (cartDetailResponse.data as List).map((data) => CartDetailModel.fromJson(data)).toList();

      // สร้าง docref: MTFyyyymmddhhmm-#### (random 4 ตัว)
      final now = DateTime.now();
      final random = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
      final docref = 'MHL${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}-$random'; // สร้าง payload
      final payload = {
        'docno': cart.docno,
        'docref': docref,
        'branchcode': global.branchCode, 'whcode': cart.whcode,
        'locationcode': cart.locationcode,
        'remark': cart.remark,
        'usercode': global.userCode,
        'docdate': cart.docdate,
        'doctime': cart.doctime.length >= 5 ? cart.doctime.substring(0, 5) : cart.doctime, // เอาแค่ HH:mm
        'details': cartDetails.map((detail) {
          return {
            'item_code': detail.itemcode,
            'item_name': detail.itemname,
            'unit_code': detail.unitcode,
            'qty': detail.qty.toString(),
            'location': detail.locationcode,
          };
        }).toList(),
      };
      final response = await client.post(
        '/approveSaveHandHeld?provider=${global.serverProvider}&dbname=${global.serverDatabase}&docno=${cart.docno}',
        data: payload,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      final rawData = json.decode(response.toString());

      // ตรวจสอบ response format ใหม่
      if (rawData['success'] == true) {
        // สำเร็จ - ใช้ docref จาก response หรือที่ gen ขึ้นมา
        return ApiResponse(
          success: true,
          message: '',
          data: {'docref': rawData['docref'] ?? docref},
        );
      } else {
        // error - return error message
        return ApiResponse(
          success: false,
          message: rawData['error'] ?? 'เกิดข้อผิดพลาดในการบันทึก',
          data: null,
        );
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> SaveReceive(CartModel cart) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      // ดึงรายละเอียดสินค้าในตะกร้า
      final cartDetailResponse = await getCartDetail(cart.docno);
      if (!cartDetailResponse.success) {
        throw Exception('ไม่สามารถดึงรายละเอียดตะกร้าได้');
      }

      final cartDetails = (cartDetailResponse.data as List).map((data) => CartDetailModel.fromJson(data)).toList();

      // สร้าง docref: MTFyyyymmddhhmm-#### (random 4 ตัว)
      final now = DateTime.now();
      final random = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
      String docref = 'MPI${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}-$random'; // สร้าง payload

      final payload = {
        'docno': cart.docno,
        'docref': docref,
        'branchcode': global.branchCode, 'whcode': cart.whcode,
        'locationcode': cart.locationcode,
        'remark': cart.remark,
        'usercode': global.userCode,
        'custcode': cart.custcode,
        'transflag': cart.transflag,
        'docdate': cart.docdate,
        'doctime': cart.doctime.length >= 5 ? cart.doctime.substring(0, 5) : cart.doctime, // เอาแค่ HH:mm
        'details': cartDetails.map((detail) {
          return {
            'item_code': detail.itemcode,
            'item_name': detail.itemname,
            'unit_code': detail.unitcode,
            'qty': detail.qty.toString(),
            'location': detail.locationcode,
          };
        }).toList(),
      };
      final response = await client.post(
        '/approveSaveReceive?provider=${global.serverProvider}&dbname=${global.serverDatabase}&docno=${cart.docno}',
        data: payload,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      final rawData = json.decode(response.toString());

      // ตรวจสอบ response format ใหม่
      if (rawData['success'] == true) {
        // สำเร็จ - ใช้ docref จาก response หรือที่ gen ขึ้นมา
        return ApiResponse(
          success: true,
          message: '',
          data: {'docref': rawData['docref'] ?? docref},
        );
      } else {
        // error - return error message
        return ApiResponse(
          success: false,
          message: rawData['error'] ?? 'เกิดข้อผิดพลาดในการบันทึก',
          data: null,
        );
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> SaveRequestTransfer(CartModel cart) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      // ดึงรายละเอียดสินค้าในตะกร้า
      final cartDetailResponse = await getCartDetail(cart.docno);
      if (!cartDetailResponse.success) {
        throw Exception('ไม่สามารถดึงรายละเอียดตะกร้าได้');
      }

      final cartDetails = (cartDetailResponse.data as List).map((data) => CartDetailModel.fromJson(data)).toList();

      // สร้าง docref: MTFyyyymmddhhmm-#### (random 4 ตัว)
      final now = DateTime.now();
      final random = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
      String docref = 'MRTF${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}-$random'; // สร้าง payload

      final payload = {
        'docno': cart.docno,
        'docref': docref,
        'branchcode': global.branchCode,
        'whcode': cart.whcode,
        'locationcode': cart.locationcode,
        'whto': cart.whto,
        'locationto': cart.locationto,
        'remark': cart.remark,
        'usercode': global.userCode,
        'custcode': cart.custcode,
        'transflag': cart.transflag,
        'docdate': cart.docdate,
        'doctime': cart.doctime.length >= 5 ? cart.doctime.substring(0, 5) : cart.doctime, // เอาแค่ HH:mm
        'details': cartDetails.map((detail) {
          return {
            'item_code': detail.itemcode,
            'item_name': detail.itemname,
            'unit_code': detail.unitcode,
            'qty': detail.qty.toString(),
            'location': detail.locationcode,
          };
        }).toList(),
      };
      final response = await client.post(
        '/approveSaveRequestTransfer?provider=${global.serverProvider}&dbname=${global.serverDatabase}&docno=${cart.docno}',
        data: payload,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      final rawData = json.decode(response.toString());

      // ตรวจสอบ response format ใหม่
      if (rawData['success'] == true) {
        // สำเร็จ - ใช้ docref จาก response หรือที่ gen ขึ้นมา
        return ApiResponse(
          success: true,
          message: '',
          data: {'docref': rawData['docref'] ?? docref},
        );
      } else {
        // error - return error message
        return ApiResponse(
          success: false,
          message: rawData['error'] ?? 'เกิดข้อผิดพลาดในการบันทึก',
          data: null,
        );
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> SaveTransfer(CartModel cart) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      // ดึงรายละเอียดสินค้าในตะกร้า
      final cartDetailResponse = await getCartDetail(cart.docno);
      if (!cartDetailResponse.success) {
        throw Exception('ไม่สามารถดึงรายละเอียดตะกร้าได้');
      }

      final cartDetails = (cartDetailResponse.data as List).map((data) => CartDetailModel.fromJson(data)).toList();

      // สร้าง docref: MTFyyyymmddhhmm-#### (random 4 ตัว)
      final now = DateTime.now();
      final random = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
      String docref = 'MTF${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}-$random'; // สร้าง payload

      final payload = {
        'docno': cart.docno,
        'docref': docref,
        'branchcode': global.branchCode,
        'whcode': cart.whcode,
        'locationcode': cart.locationcode,
        'whto': cart.whto,
        'locationto': cart.locationto,
        'remark': cart.remark,
        'usercode': global.userCode,
        'custcode': cart.custcode,
        'transflag': cart.transflag,
        'docdate': cart.docdate,
        'doctime': cart.doctime.length >= 5 ? cart.doctime.substring(0, 5) : cart.doctime, // เอาแค่ HH:mm
        'details': cartDetails.map((detail) {
          return {
            'item_code': detail.itemcode,
            'item_name': detail.itemname,
            'unit_code': detail.unitcode,
            'qty': detail.qty.toString(),
            'location': detail.locationcode,
          };
        }).toList(),
      };
      final response = await client.post(
        '/approveSaveTransfer?provider=${global.serverProvider}&dbname=${global.serverDatabase}&docno=${cart.docno}',
        data: payload,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      final rawData = json.decode(response.toString());

      // ตรวจสอบ response format ใหม่
      if (rawData['success'] == true) {
        // สำเร็จ - ใช้ docref จาก response หรือที่ gen ขึ้นมา
        return ApiResponse(
          success: true,
          message: '',
          data: {'docref': rawData['docref'] ?? docref},
        );
      } else {
        // error - return error message
        return ApiResponse(
          success: false,
          message: rawData['error'] ?? 'เกิดข้อผิดพลาดในการบันทึก',
          data: null,
        );
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> sendCart(String docno) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.get('/sendCart?provider=${global.serverProvider}&dbname=${global.serverDatabase}&docno=$docno');
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> sendSubCart(String docno) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.get('/sendSubCart?provider=${global.serverProvider}&dbname=${global.serverDatabase}&docno=$docno');
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> deleteCart(String docno) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.get('/deleteCart?provider=${global.serverProvider}&dbname=${global.serverDatabase}&docno=$docno');
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> createCart(String docno, String whcode, String locationcode, String remark, String docdate, String doctime, String custcode, int transflag, {String whto = '', String locationto = ''}) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.post('/createCart?provider=${global.serverProvider}&dbname=${global.serverDatabase}', data: {
        'docno': docno,
        'whcode': whcode,
        'locationcode': locationcode,
        'remark': remark,
        'usercode': global.userCode,
        'branchcode': global.branchCode,
        'docdate': docdate,
        'doctime': doctime,
        'custcode': custcode,
        'transflag': transflag.toString(),
        'whto': whto,
        'locationto': locationto
      });
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> mergeCart(String docno, String docdate, String doctime, String whcode, String locationcode, String remark, String carts, String custcode, int transflag, {String whto = '', String locationto = ''}) async {
    global.loadConfig();
    Dio client = Client().init();
    var postData = {
      'docno': docno,
      'whcode': whcode,
      'locationcode': locationcode,
      'remark': remark,
      'usercode': global.userCode,
      'branchcode': global.branchCode,
      'docdate': docdate,
      'doctime': doctime,
      'carts': carts,
      'custcode': custcode,
      'transflag': transflag.toString(),
      'whto': whto,
      'locationto': locationto
    };
    try {
      final response = await client.post('/mergeCart?provider=${global.serverProvider}&dbname=${global.serverDatabase}', data: postData);
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> saveCartDetail(List<ItemScanModel> item, CartModel cart) async {
    global.loadConfig();
    Dio client = Client().init();

    var detail = item.map((e) => e.toJson()).toList();
    try {
      final response = await client.post('/saveCartDetail?provider=${global.serverProvider}&dbname=${global.serverDatabase}', data: {'docno': cart.docno, 'whcode': cart.whcode, 'locationcode': cart.locationcode, 'details': detail});
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> saveCartSubDetail(List<ItemScanModel> item, CartModel cart) async {
    global.loadConfig();
    Dio client = Client().init();
    var detail = item.map((e) => e.toJson()).toList();
    try {
      final response = await client.post('/saveCartSubDetail?provider=${global.serverProvider}&dbname=${global.serverDatabase}', data: {'docno': cart.docno, 'whcode': cart.whcode, 'locationcode': cart.locationcode, 'details': detail});
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> updateCart(String docno, String whcode, String locationcode, String remark, String docdate, String doctime, String custcode, {String whto = '', String locationto = ''}) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.post('/updateCart?provider=${global.serverProvider}&dbname=${global.serverDatabase}',
          data: {'docno': docno, 'whcode': whcode, 'locationcode': locationcode, 'remark': remark, 'usercode': global.userCode, 'branchcode': global.branchCode, 'docdate': docdate, 'doctime': doctime, 'custcode': custcode, 'whto': whto, 'locationto': locationto});
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> querySelect(String query) async {
    Map<String, dynamic> requestData = {
      'provider': global.serverProvider.toUpperCase(),
      'database': global.serverDatabase.toLowerCase(),
      'query': query,
    };

    // Compress and encode your request data
    String jsonRequest = jsonEncode(requestData);
    List<int> compressedData = await compress(jsonRequest);
    String base64Request = base64Encode(compressedData);

    try {
      global.loadConfig();
      Dio client = Client().init();
      var response = await client.post(
        '/webresources/rest/select',
        data: base64Request,
        options: Options(
          headers: {
            Headers.contentTypeHeader: 'application/octet-stream',
          },
        ),
      );

      if (response.statusCode == 200) {
        Uint8List decodedBytes = base64Decode(response.data);
        String decompressedResponse = utf8.decode(GZipDecoder().decodeBytes(decodedBytes));
        Map<String, dynamic> result = jsonDecode(decompressedResponse);
        return ApiResponse.fromMap({
          'success': true,
          'data': result.isNotEmpty ? result['data'] : [],
        });
      } else {
        throw Exception('${response.statusCode}: ${response.statusMessage}');
      }
    } catch (e) {
      print('An error occurred: $e');
      throw Exception(e.toString());
    }
  }

  Future<Uint8List> compress(String data) async {
    List<int> utf8Bytes = utf8.encode(data);
    List<int> gzipBytes = GZipCodec().encode(utf8Bytes);
    return Uint8List.fromList(gzipBytes);
  }

  Future<String> decompress(Uint8List compressed) async {
    if (compressed.isEmpty) {
      return "";
    }

    if (_isCompressed(compressed)) {
      final GZipCodec gzip = GZipCodec();
      List<int> decompressedBytes = gzip.decode(compressed);
      return utf8.decode(decompressedBytes);
    } else {
      return String.fromCharCodes(compressed);
    }
  }

  bool _isCompressed(Uint8List compressed) {
    return true;
  }

  // ดึงรายการสินค้า
  Future<ApiResponse> getItemList(String search) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.get('/getItemList?provider=${global.serverProvider}&dbname=${global.serverDatabase}&search=$search');
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  // ดึงหน่วยนับ
  Future<ApiResponse> getItemUnit(String itemCode) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.get('/getItemUnit?provider=${global.serverProvider}&dbname=${global.serverDatabase}&itemcode=$itemCode');
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  // ดึงราคาสินค้า
  Future<ApiResponse> getItemPrice(String itemCode) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.get('/getItemPrice?provider=${global.serverProvider}&dbname=${global.serverDatabase}&itemcode=$itemCode');
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> getItemBarcodePrice(String itemCode) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.get('/getItemBarcodePrice?provider=${global.serverProvider}&dbname=${global.serverDatabase}&itemcode=$itemCode');
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> getItemPriceNormal(String itemCode) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.get('/getItemPriceNormal?provider=${global.serverProvider}&dbname=${global.serverDatabase}&itemcode=$itemCode');
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  Future<ApiResponse> getItemPriceStandard(String itemCode) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.get('/getItemPriceStandard?provider=${global.serverProvider}&dbname=${global.serverDatabase}&itemcode=$itemCode');
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  // ดึงข้อมูลสต๊อกสินค้า
  Future<ApiResponse> getStockDetail(String itemCode) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.get('/getStockDetail?provider=${global.serverProvider}&dbname=${global.serverDatabase}&itemcode=$itemCode');
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }

  // ดึงข้อมูลค้างรับ/ค้างจอง/ค้างส่ง
  Future<ApiResponse> getAccrued(String itemCode) async {
    global.loadConfig();
    Dio client = Client().init();

    try {
      final response = await client.get('/getAccrued?provider=${global.serverProvider}&dbname=${global.serverDatabase}&itemcode=$itemCode');
      try {
        final rawData = json.decode(response.toString());
        if (rawData['error'] != null) {
          throw Exception('${rawData['code']}: ${rawData['message']}');
        }
        return ApiResponse.fromMap(rawData);
      } catch (ex) {
        throw Exception(ex);
      }
    } on DioException catch (ex) {
      String errorMessage = ex.response.toString();
      throw Exception(errorMessage);
    }
  }
}
