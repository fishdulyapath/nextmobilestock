import 'package:flutter/material.dart';
import 'package:mobilestock/repository/webservice_repository.dart';
import 'package:mobilestock/global.dart' as global;
import 'package:intl/intl.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemCode;
  final String itemName;

  const ItemDetailScreen({
    super.key,
    required this.itemCode,
    required this.itemName,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final WebServiceRepository _webServiceRepository = WebServiceRepository();

  // Price data
  List<Map<String, dynamic>> _priceDataList = [];
  String _selectedUnit = "";
  bool _isLoadingPrice = true;
  String _priceError = '';

  // Unit data
  List<Map<String, dynamic>> _unitData = [];
  bool _isLoadingUnit = true;
  String _unitError = '';

  // Stock data
  List<Map<String, dynamic>> _stockData = [];
  bool _isLoadingStock = true;
  String _stockError = '';

  // Accrued data
  Map<String, dynamic>? _accruedData;
  bool _isLoadingAccrued = true;
  String _accruedError = '';

  // Barcode Price data
  List<Map<String, dynamic>> _priceBarcodeDataList = [];
  bool _isLoadingBarcodePrice = true;
  String _priceBarcodeError = '';

  // Normal Price data
  List<Map<String, dynamic>> _priceNormalDataList = [];
  bool _isLoadingNormalPrice = true;
  String _priceNormalError = '';

  // Standard Price data
  List<Map<String, dynamic>> _priceStandardDataList = [];
  bool _isLoadingStandardPrice = true;
  String _priceStandardError = '';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    // Load all data in parallel
    await Future.wait([
      _loadUnitData(),
      _loadPriceData(),
      _loadPriceStandard(),
      _loadPriceNormal(),
      _loadBarcodePrice(),
      _loadStockData(),
      _loadAccruedData(),
    ]);
  }

  Future<void> _loadUnitData() async {
    try {
      final result = await _webServiceRepository.getItemUnit(widget.itemCode);
      if (result.success && result.data != null) {
        setState(() {
          _unitData = List<Map<String, dynamic>>.from(result.data);
          _selectedUnit = _unitData.isNotEmpty ? _unitData[0]['unit_code'] : "";
          _isLoadingUnit = false;
        });
      } else {
        setState(() {
          _unitError = 'ไม่พบข้อมูลหน่วย';
          _isLoadingUnit = false;
        });
      }
    } catch (e) {
      setState(() {
        _unitError = e.toString();
        _isLoadingUnit = false;
      });
    }
  }

  Future<void> _loadPriceData() async {
    try {
      final result = await _webServiceRepository.getItemPrice(widget.itemCode);
      if (result.success && result.data != null && (result.data as List).isNotEmpty) {
        setState(() {
          _priceDataList = List<Map<String, dynamic>>.from(result.data);
          // Default to first item
          _isLoadingPrice = false;
        });
      } else {
        setState(() {
          _priceError = 'ไม่พบข้อมูลราคา';
          _isLoadingPrice = false;
        });
      }
    } catch (e) {
      setState(() {
        _priceError = e.toString();
        _isLoadingPrice = false;
      });
    }
  }

  Future<void> _loadPriceNormal() async {
    try {
      final result = await _webServiceRepository.getItemPriceNormal(widget.itemCode);
      if (result.success && result.data != null && (result.data as List).isNotEmpty) {
        setState(() {
          _priceNormalDataList = List<Map<String, dynamic>>.from(result.data);
          // Default to first item
          _isLoadingNormalPrice = false;
        });
      } else {
        setState(() {
          _priceNormalError = 'ไม่พบข้อมูลราคา';
          _isLoadingNormalPrice = false;
        });
      }
    } catch (e) {
      setState(() {
        _priceNormalError = e.toString();
        _isLoadingNormalPrice = false;
      });
    }
  }

  Future<void> _loadPriceStandard() async {
    try {
      final result = await _webServiceRepository.getItemPriceStandard(widget.itemCode);
      if (result.success && result.data != null && (result.data as List).isNotEmpty) {
        setState(() {
          _priceStandardDataList = List<Map<String, dynamic>>.from(result.data);
          // Default to first item
          _isLoadingStandardPrice = false;
        });
      } else {
        setState(() {
          _priceStandardError = 'ไม่พบข้อมูลราคา';
          _isLoadingStandardPrice = false;
        });
      }
    } catch (e) {
      setState(() {
        _priceStandardError = e.toString();
        _isLoadingStandardPrice = false;
      });
    }
  }

  Future<void> _loadBarcodePrice() async {
    try {
      final result = await _webServiceRepository.getItemBarcodePrice(widget.itemCode);
      if (result.success && result.data != null && (result.data as List).isNotEmpty) {
        setState(() {
          _priceBarcodeDataList = List<Map<String, dynamic>>.from(result.data);
          // Default to first item
          _isLoadingBarcodePrice = false;
        });
      } else {
        setState(() {
          _priceBarcodeError = 'ไม่พบข้อมูลราคา';
          _isLoadingBarcodePrice = false;
        });
      }
    } catch (e) {
      setState(() {
        _priceBarcodeError = e.toString();
        _isLoadingBarcodePrice = false;
      });
    }
  }

  Future<void> _loadStockData() async {
    try {
      final result = await _webServiceRepository.getStockDetail(widget.itemCode);
      if (result.success) {
        setState(() {
          _stockData = List<Map<String, dynamic>>.from(result.data ?? []);
          _isLoadingStock = false;
        });
      } else {
        setState(() {
          _stockError = result.message ?? 'เกิดข้อผิดพลาด';
          _isLoadingStock = false;
        });
      }
    } catch (e) {
      setState(() {
        _stockError = e.toString();
        _isLoadingStock = false;
      });
    }
  }

  Future<void> _loadAccruedData() async {
    try {
      final result = await _webServiceRepository.getAccrued(widget.itemCode);
      if (result.success && result.data != null && (result.data as List).isNotEmpty) {
        setState(() {
          _accruedData = (result.data as List).first;
          _isLoadingAccrued = false;
        });
      } else {
        setState(() {
          _accruedError = 'ไม่พบข้อมูล';
          _isLoadingAccrued = false;
        });
      }
    } catch (e) {
      setState(() {
        _accruedError = e.toString();
        _isLoadingAccrued = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'รายละเอียดสินค้า',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Header
              _buildItemHeader(),

              // Price Section
              _buildPriceSection(),

              // Accrued Section
              _buildAccruedSection(),

              // Stock Section
              _buildStockSection(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // รูปสินค้า หรือ Icon ถ้าไม่มีรูป
          _buildItemImage(widget.itemCode),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.itemCode,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.itemName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (_unitData.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'หน่วย: ${_unitData.firstWhere((item) => item['unit_code'] == _selectedUnit)['unit_code']}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.attach_money, color: Color(0xFF10B981), size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'ตารางราคา',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              // Unit selector dropdown
              if (_unitData.length > 1 && !_isLoadingUnit) _buildUnitSelector(),
            ],
          ),
          const SizedBox(height: 12),
          // ราคาตามสูตร
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _isLoadingPrice
                ? const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
                  )
                : _priceError.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(_priceError, style: TextStyle(color: Colors.grey.shade500)),
                        ),
                      )
                    : _buildPriceTable(),
          ),
          const SizedBox(height: 12),
          // ราคาตามมาตรฐาน
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _isLoadingStandardPrice
                ? const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
                  )
                : _priceStandardError.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(_priceStandardError, style: TextStyle(color: Colors.grey.shade500)),
                        ),
                      )
                    : _buildPriceStandardTable(),
          ),
          const SizedBox(height: 12),
          // ราคาทั่วไป
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _isLoadingNormalPrice
                ? const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
                  )
                : _priceNormalError.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(_priceNormalError, style: TextStyle(color: Colors.grey.shade500)),
                        ),
                      )
                    : _buildPriceNormalTable(),
          ),
          const SizedBox(height: 12),
          //ราคาตามบาร์โค้ด
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _isLoadingBarcodePrice
                ? const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
                  )
                : _priceBarcodeError.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(_priceBarcodeError, style: TextStyle(color: Colors.grey.shade500)),
                        ),
                      )
                    : _buildBarcodePriceTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSelector() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedUnit,
          isDense: true,
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.arrow_drop_down,
              color: Color(0xFF10B981),
              size: 18,
            ),
          ),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
            letterSpacing: 0.2,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: 8,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          items: _unitData.asMap().entries.map((entry) {
            final index = entry.key;
            final unitData = entry.value;
            final unitCode = unitData['unit_code'] ?? '-';
            final isSelected = unitCode == _selectedUnit;

            return DropdownMenuItem<String>(
              value: unitCode,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                      width: index < _unitData.length - 1 ? 1 : 0,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      unitCode,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newIndex) {
            if (newIndex != null) {
              setState(() {
                _selectedUnit = newIndex;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildBarcodePriceTable() {
    if (_priceBarcodeDataList.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(20),
        child: Container(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ราคาตามบาร์โค้ด',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          ..._priceBarcodeDataList.map((selectedPrice) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHeaderCell(selectedPrice['barcode'] ?? ''),
                        _buildHeaderCell(selectedPrice['unit_code'] ?? ''),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildPriceCell('ราคา1', selectedPrice['price'] ?? '0'),
                        _buildPriceCell('ราคา2', selectedPrice['price_2'] ?? '0'),
                        _buildPriceCell('ราคา3', selectedPrice['price_3'] ?? '0'),
                        _buildPriceCell('ราคา4', selectedPrice['price_4'] ?? '0'),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPriceStandardTable() {
    if (_priceStandardDataList.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(20),
        child: Container(),
      );
    }

    final selectedPrice = _priceStandardDataList.where(
      (price) => price['unit_code'] == _selectedUnit,
    );

    if (selectedPrice.isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ราคาทั่วไป',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          ...selectedPrice.map((selectedPrice) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTextCell('จากวันที่', selectedPrice['from_date'] ?? ''),
                        _buildTextCell('ถึงวันที่', selectedPrice['to_date'] ?? ''),
                        _buildTextCell('จากจำนวน', selectedPrice['from_qty'] ?? ''),
                        _buildTextCell('ถึงจำนวน', selectedPrice['to_qty'] ?? ''),
                        _buildTextCell('ลูกค้า', selectedPrice['cust_code'] ?? ''),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTextCell('CustGroup1', selectedPrice['cust_group_1'] ?? ''),
                        _buildTextCell('CustGroup2', selectedPrice['cust_group_2'] ?? ''),
                        _buildTextCell('SaleType', selectedPrice['sale_type'] ?? ''),
                        _buildTextCell('PriceType', selectedPrice['price_type'] ?? ''),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        _buildPriceCell('ราคา1', selectedPrice['sale_price1'] ?? '0'),
                        _buildPriceCell('ราคา2', selectedPrice['sale_price2'] ?? '0'),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPriceNormalTable() {
    if (_priceNormalDataList.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(20),
        child: Container(),
      );
    }

    final selectedPrice = _priceNormalDataList.where(
      (price) => price['unit_code'] == _selectedUnit,
    );

    if (selectedPrice.isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ราคามาตรฐาน',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          ...selectedPrice.map((selectedPrice) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTextCell('จากวันที่', selectedPrice['from_date'] ?? ''),
                        _buildTextCell('ถึงวันที่', selectedPrice['to_date'] ?? ''),
                        _buildTextCell('จากจำนวน', selectedPrice['from_qty'] ?? ''),
                        _buildTextCell('ถึงจำนวน', selectedPrice['to_qty'] ?? ''),
                        _buildTextCell('ลูกค้า', selectedPrice['cust_code'] ?? ''),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTextCell('CustGroup1', selectedPrice['cust_group_1'] ?? ''),
                        _buildTextCell('CustGroup2', selectedPrice['cust_group_2'] ?? ''),
                        _buildTextCell('SaleType', selectedPrice['sale_type'] ?? ''),
                        _buildTextCell('PriceType', selectedPrice['price_type'] ?? ''),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        _buildPriceCell('ราคา1', selectedPrice['sale_price1'] ?? '0'),
                        _buildPriceCell('ราคา2', selectedPrice['sale_price2'] ?? '0'),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPriceTable() {
    if (_priceDataList.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(20),
        child: Container(),
      );
    }

    final selectedPrice = _priceDataList.firstWhere(
      (price) => price['unit_code'] == _selectedUnit,
      orElse: () => {},
    );

    if (selectedPrice.isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ราคาตามสูตร',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          // Price Row 1 (0-4)
          Row(
            children: [
              _buildPriceCell('ราคา 0', selectedPrice['price_0'] ?? '0'),
              _buildPriceCell('ราคา 1', selectedPrice['price_1'] ?? '0'),
              _buildPriceCell('ราคา 2', selectedPrice['price_2'] ?? '0'),
              _buildPriceCell('ราคา 3', selectedPrice['price_3'] ?? '0'),
              _buildPriceCell('ราคา 4', selectedPrice['price_4'] ?? '0'),
            ],
          ),
          const SizedBox(height: 3),
          // Price Row 2 (5-9)
          Row(
            children: [
              _buildPriceCell('ราคา 5', selectedPrice['price_5'] ?? '0'),
              _buildPriceCell('ราคา 6', selectedPrice['price_6'] ?? '0'),
              _buildPriceCell('ราคา 7', selectedPrice['price_7'] ?? '0'),
              _buildPriceCell('ราคา 8', selectedPrice['price_8'] ?? '0'),
              _buildPriceCell('ราคา 9', selectedPrice['price_9'] ?? '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextCell(String label, dynamic text) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCell(String label, dynamic price) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatPrice(price),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccruedSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.pending_actions, color: Color(0xFF8B5CF6), size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'ค้างรับ / ค้างจอง / ค้างส่ง',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _isLoadingAccrued
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
                  )
                : _accruedError.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(_accruedError, style: TextStyle(color: Colors.grey.shade500)),
                        ),
                      )
                    : _buildAccruedContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccruedContent() {
    if (_accruedData == null) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('ไม่พบข้อมูล')),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _buildAccruedCard(
            'ค้างรับ',
            _accruedData!['accrued_in_qty'],
            Icons.call_received,
            const Color(0xFF10B981),
          ),
          const SizedBox(width: 8),
          _buildAccruedCard(
            'ค้างจอง',
            _accruedData!['book_out_qty'],
            Icons.bookmark_outline,
            const Color(0xFFF59E0B),
          ),
          const SizedBox(width: 8),
          _buildAccruedCard(
            'ค้างส่ง',
            _accruedData!['accrued_out_qty'],
            Icons.call_made,
            const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildAccruedCard(String label, dynamic qty, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatQty(qty),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warehouse_outlined, color: Color(0xFF3B82F6), size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'สต๊อกตามคลัง',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _isLoadingStock
                ? const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
                  )
                : _stockError.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(_stockError, style: TextStyle(color: Colors.grey.shade500)),
                        ),
                      )
                    : _buildStockList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStockList() {
    if (_stockData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('ไม่พบข้อมูลสต๊อก')),
      );
    }

    // Filter out empty warehouse names
    final validStockData = _stockData.where((stock) {
      final whName = stock['wh_name']?.toString() ?? '';
      return whName.isNotEmpty;
    }).toList();

    if (validStockData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('ไม่พบข้อมูลสต๊อก')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: validStockData.length,
      separatorBuilder: (context, index) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final stock = validStockData[index];
        return _buildStockItem(stock);
      },
    );
  }

  Widget _buildStockItem(Map<String, dynamic> stock) {
    final whName = stock['wh_name']?.toString() ?? '-';
    final shelfName = stock['shelf_name']?.toString() ?? '-';
    final balanceQty = stock['balance_qty']?.toString() ?? '0';
    final unitCode = stock['unit_code']?.toString() ?? '';

    final qty = double.tryParse(balanceQty) ?? 0;
    final isPositive = qty > 0;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isPositive ? const Color(0xFF10B981).withOpacity(0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.store_outlined,
            color: isPositive ? const Color(0xFF10B981) : Colors.grey.shade400,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                whName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (shelfName.isNotEmpty && shelfName != '-')
                Text(
                  'ชั้นวาง: $shelfName',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPositive ? const Color(0xFF10B981).withOpacity(0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${_formatQty(balanceQty)} $unitCode',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isPositive ? const Color(0xFF10B981) : Colors.grey.shade500,
            ),
          ),
        ),
      ],
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0.00';
    final value = double.tryParse(price.toString()) ?? 0;
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(value);
  }

  String _formatQty(dynamic qty) {
    if (qty == null) return '0';
    final value = double.tryParse(qty.toString()) ?? 0;
    if (value == value.roundToDouble()) {
      final formatter = NumberFormat('#,##0');
      return formatter.format(value.toInt());
    }
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(value);
  }

  // สร้าง URL สำหรับดึงรูปสินค้า
  String _getItemImageUrl(String itemCode) {
    return '${global.serverHost}/NextStepMobileStockServiceAPI/service/v1/images?provider=${global.serverProvider}&dbname=${global.serverDatabase}&itemcode=$itemCode';
  }

  // Widget แสดงรูปสินค้า หรือ icon ถ้าไม่มีรูป
  Widget _buildItemImage(String itemCode) {
    final imageUrl = _getItemImageUrl(itemCode);

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          imageUrl,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // ถ้าโหลดรูปไม่ได้ (404 หรือ error อื่น) แสดง icon แทน
            return Container(
              padding: const EdgeInsets.all(14),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: Color(0xFF3B82F6),
                size: 32,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: const Color(0xFF3B82F6).withOpacity(0.5),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
