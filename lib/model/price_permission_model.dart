class PricePermissionModel {
  final String code;
  final String name;
  final List<bool> prices;

  const PricePermissionModel({
    required this.code,
    required this.name,
    required this.prices,
  });

  factory PricePermissionModel.fromJson(Map<String, dynamic> json) {
    return PricePermissionModel(
      code: json['code'] ?? '',
      name: json['name_1'] ?? '',
      prices:
          List.generate(10, (index) => json['price_$index'].toString() == '1'),
    );
  }

  PricePermissionModel copyWith({
    List<bool>? prices,
  }) {
    return PricePermissionModel(
      code: code,
      name: name,
      prices: prices ?? this.prices,
    );
  }

  bool get isAllChecked => prices.every((value) => value);
  int get checkedCount => prices.where((value) => value).length;
}
