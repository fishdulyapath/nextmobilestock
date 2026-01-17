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
  Map<String, dynamic>? _priceData;
  bool _isLoadingPrice = true;
  String _priceError = '';

  // Stock data
  List<Map<String, dynamic>> _stockData = [];
  bool _isLoadingStock = true;
  String _stockError = '';

  // Accrued data
  Map<String, dynamic>? _accruedData;
  bool _isLoadingAccrued = true;
  String _accruedError = '';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    // Load all data in parallel
    await Future.wait([
      _loadPriceData(),
      _loadStockData(),
      _loadAccruedData(),
    ]);
  }

  Future<void> _loadPriceData() async {
    try {
      final result = await _webServiceRepository.getItemPrice(widget.itemCode);
      if (result.success && result.data != null && (result.data as List).isNotEmpty) {
        setState(() {
          _priceData = (result.data as List).first;
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
                if (_priceData != null && _priceData!['unit_code'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'หน่วย: ${_priceData!['unit_code']}',
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
        ],
      ),
    );
  }

  Widget _buildPriceTable() {
    if (_priceData == null) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('ไม่พบข้อมูลราคา')),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Average Cost
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.trending_up, color: Color(0xFFD97706), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'ราคาทุนเฉลี่ย: ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF92400E),
                  ),
                ),
                Text(
                  _formatPrice(_priceData!['average_cost']),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Price Row 1 (0-4)
          Row(
            children: [
              _buildPriceCell('ราคา 0', _priceData!['price_0']),
              _buildPriceCell('ราคา 1', _priceData!['price_1']),
              _buildPriceCell('ราคา 2', _priceData!['price_2']),
              _buildPriceCell('ราคา 3', _priceData!['price_3']),
              _buildPriceCell('ราคา 4', _priceData!['price_4']),
            ],
          ),
          const SizedBox(height: 8),
          // Price Row 2 (5-9)
          Row(
            children: [
              _buildPriceCell('ราคา 5', _priceData!['price_5']),
              _buildPriceCell('ราคา 6', _priceData!['price_6']),
              _buildPriceCell('ราคา 7', _priceData!['price_7']),
              _buildPriceCell('ราคา 8', _priceData!['price_8']),
              _buildPriceCell('ราคา 9', _priceData!['price_9']),
            ],
          ),
        ],
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
