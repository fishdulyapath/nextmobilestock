class PermissionModel {
  final String code;
  final String name;
  final bool stockList;
  final bool requestList;
  final bool transferList;
  final bool handheldList;
  final bool barcodeList;
  final bool permissionList;
  final bool infoList;

  const PermissionModel({
    required this.code,
    required this.name,
    required this.stockList,
    required this.requestList,
    required this.transferList,
    required this.handheldList,
    required this.barcodeList,
    required this.infoList,
    required this.permissionList,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      code: json['code'] ?? '',
      name: json['name_1'] ?? '',
      stockList: json['stock_list'] == '1',
      requestList: json['request_list'] == '1',
      transferList: json['transfer_list'] == '1',
      handheldList: json['handheld_list'] == '1',
      barcodeList: json['barcode_list'] == '1',
      permissionList: json['permission_list'] == '1',
      infoList: json['info_list'] == '1',
    );
  }

  PermissionModel copyWith({
    bool? stockList,
    bool? requestList,
    bool? transferList,
    bool? handheldList,
    bool? barcodeList,
    bool? infoList,
    bool? permissionList,
  }) {
    return PermissionModel(
      code: code,
      name: name,
      stockList: stockList ?? this.stockList,
      requestList: requestList ?? this.requestList,
      transferList: transferList ?? this.transferList,
      handheldList: handheldList ?? this.handheldList,
      barcodeList: barcodeList ?? this.barcodeList,
      infoList: infoList ?? this.infoList,
      permissionList: permissionList ?? this.permissionList,
    );
  }
}
