import 'package:flutter/material.dart';
import 'package:mobilestock/features/cart/cart_item_search.dart';
import 'package:mobilestock/model/cart_model.dart';
import 'package:mobilestock/model/item_model.dart';
import 'package:mobilestock/repository/webservice_repository.dart';
import 'package:mobilestock/global.dart' as global;

class RequestCartReadDetailScreen extends StatefulWidget {
  final CartModel cart;
  final int ismerge;
  const RequestCartReadDetailScreen({super.key, required this.cart, required this.ismerge});

  @override
  State<RequestCartReadDetailScreen> createState() => _RequestCartReadDetailScreenState();
}

class _RequestCartReadDetailScreenState extends State<RequestCartReadDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final WebServiceRepository _webServiceRepository = WebServiceRepository();
  FocusNode textfocusNode = FocusNode();
  List<ItemScanModel> itemScanList = [];
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    textfocusNode.dispose();
    super.dispose();
  }

  void getItemDetail() async {
    var textsplit = _controller.text.split('*');
    var barcode = "";
    var qty = 1;
    if (textsplit.length > 1) {
      barcode = textsplit[1];
      qty = int.parse(textsplit[0]);
    } else {
      barcode = textsplit[0];
    }
    await _webServiceRepository.getItemDetail(barcode, widget.cart.whcode, widget.cart.locationcode).then((value) {
      if (value.success) {
        textfocusNode.requestFocus();
        if (value.data.length > 0) {
          ItemModel item = ItemModel.fromJson(value.data[0]);

          ItemScanModel checkdata = itemScanList.firstWhere((ele) => ele.itemcode == item.itemcode && ele.unitcode == item.unitcode, orElse: () => ItemScanModel(barcode: "", itemcode: "", unitcode: "", itemname: ""));

          if (checkdata.itemcode == "") {
            setState(() {
              itemScanList.insert(0, ItemScanModel(barcode: item.barcode, itemcode: item.itemcode, unitcode: item.unitcode, itemname: item.itemname, qty: qty, balanceqty: double.parse(item.balanceqty)));
              _controller.text = "";
            });
          } else {
            setState(() {
              int index = itemScanList.indexOf(checkdata);
              itemScanList[index].qty += qty;
              ItemScanModel updatedItem = itemScanList.removeAt(index);
              itemScanList.insert(0, updatedItem);
              _controller.text = "";
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("ไม่พบข้อมูลสินค้า"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void getCartDetail() async {
    await _webServiceRepository.getCartDetail(widget.cart.docno).then((value) {
      if (value.success) {
        if (value.data.length > 0) {
          setState(() {
            itemScanList = (value.data as List).map((data) => ItemScanModel.fromJson(data)).toList();
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  @override
  void initState() {
    getCartDetail();
    super.initState();
  }

  // Method สำหรับ filter รายการสินค้า
  List<ItemScanModel> get _displayList {
    if (_searchQuery.isEmpty) {
      return itemScanList;
    }
    return itemScanList.where((item) {
      final query = _searchQuery.toLowerCase();
      return item.itemname.toLowerCase().contains(query) || item.itemcode.toLowerCase().contains(query) || item.barcode.toLowerCase().contains(query);
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'รายละเอียดสินค้า',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        color: Color(0xFF3B82F6),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.cart.docno,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.ismerge == 0)
            Container(
              padding: const EdgeInsets.all(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onSubmitted: (value) => getItemDetail(),
                        focusNode: textfocusNode,
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'สแกนหรือพิมพ์บาร์โค้ด...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.qr_code_scanner, color: Colors.grey.shade400),
                        ),
                      ),
                    ),
                    _buildActionButton(
                      icon: Icons.search,
                      color: const Color(0xFF3B82F6),
                      onTap: () async {
                        final res = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CartItemSearch()),
                        );
                        if (res != null) {
                          ItemModel item = res as ItemModel;
                          setState(() {
                            _controller.text += item.barcode;
                            getItemDetail();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          // Search bar สำหรับโหมดอ่านอย่างเดียว (ismerge != 0)
          if (widget.ismerge != 0 && itemScanList.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'ค้นหาสินค้า...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      _buildActionButton(
                        icon: Icons.clear,
                        color: Colors.grey,
                        onTap: _clearSearch,
                      ),
                  ],
                ),
              ),
            ),
          if (widget.ismerge != 0 && itemScanList.isNotEmpty) const SizedBox(height: 8),
          if (itemScanList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Text(
                    'รายการสินค้า',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  if (_searchQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'พบ ${_displayList.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${itemScanList.length} รายการ',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: itemScanList.isEmpty
                ? _buildEmptyState()
                : _displayList.isEmpty
                    ? _buildNoSearchResultState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: _displayList.length,
                        itemBuilder: (context, index) => _buildItemCardFromList(_displayList[index], index),
                      ),
          ),
          if (widget.ismerge == 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: itemScanList.isEmpty ? null : _showConfirmSaveDialog,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_outlined, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                'บันทึกรายการ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ยังไม่มีรายการสินค้า',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'สแกนบาร์โค้ดหรือค้นหาสินค้าเพื่อเพิ่มรายการ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResultState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off,
              size: 48,
              color: Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ไม่พบสินค้าที่ค้นหา',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ลองค้นหาด้วยชื่อ, รหัส หรือบาร์โค้ดอื่น',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _clearSearch,
            icon: const Icon(Icons.clear, size: 18),
            label: const Text('ล้างการค้นหา'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(int index) {
    final item = itemScanList[index];
    return _buildItemCardFromList(item, index);
  }

  Widget _buildItemCardFromList(ItemScanModel item, int displayIndex) {
    // หา index จริงใน itemScanList สำหรับ edit/delete
    final actualIndex = itemScanList.indexWhere((i) => i.itemcode == item.itemcode && i.unitcode == item.unitcode);
    final imageUrl = '${global.serverHost}/NextStepMobileStockServiceAPI/service/v1/images?provider=${global.serverProvider}&dbname=${global.serverDatabase}&itemcode=${item.itemcode}';

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.grey.shade400,
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemname,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.itemcode,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.unitcode,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ), // Quantity - Tap to edit
            if (widget.ismerge == 0)
              GestureDetector(
                onTap: () => _showEditQuantityDialog(actualIndex),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${item.qty}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: Color(0xFF10B981),
                      ),
                    ],
                  ),
                ),
              ),
            // Quantity - View only (merged)
            if (widget.ismerge != 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${item.qty}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            if (widget.ismerge == 0)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                  onPressed: () => _showConfirmDialog(actualIndex),
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade400,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showEditQuantityDialog(int index) {
    final item = itemScanList[index];
    final TextEditingController qtyController = TextEditingController(text: item.qty.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_outlined, color: Color(0xFF3B82F6), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('แก้ไขจำนวน', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item name
              Text(
                item.itemname,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${item.itemcode} | ${item.unitcode}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              // Quantity input with +/- buttons
              Row(
                children: [
                  // Minus button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        int currentQty = int.tryParse(qtyController.text) ?? 0;
                        if (currentQty > 1) {
                          qtyController.text = (currentQty - 1).toString();
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.remove, color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Input field
                  Expanded(
                    child: TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Plus button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        int currentQty = int.tryParse(qtyController.text) ?? 0;
                        qtyController.text = (currentQty + 1).toString();
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add, color: Color(0xFF10B981)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ยกเลิก', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                int newQty = int.tryParse(qtyController.text) ?? 0;
                if (newQty > 0) {
                  setState(() {
                    itemScanList[index].qty = newQty;
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.white),
                          SizedBox(width: 10),
                          Text("จำนวนต้องมากกว่า 0"),
                        ],
                      ),
                      backgroundColor: const Color(0xFFF59E0B),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              child: const Text('บันทึก', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showExitConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 24),
              ),
              const SizedBox(width: 12),
              const Text('ยืนยันการออก', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: const Text('ข้อมูลที่ยังไม่ได้บันทึกจะหายไป\nต้องการออกจากหน้านี้ใช่หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ยกเลิก', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('ออก', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  _showConfirmDialog(index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 24),
              ),
              const SizedBox(width: 12),
              const Text('ยืนยันการลบ', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: const Text('ต้องการลบรายการนี้ใช่หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ยกเลิก', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                setState(() {
                  itemScanList.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text('ลบ', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  _showConfirmSaveDialog() {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.save_outlined, color: Color(0xFF10B981), size: 24),
              ),
              const SizedBox(width: 12),
              const Text('ยืนยันการบันทึก', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Text('บันทึกรายการสินค้าทั้งหมด ${itemScanList.length} รายการ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('ยกเลิก', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                if (!mounted) return;
                setState(() => _isLoading = true);

                try {
                  final value = await _webServiceRepository.saveCartDetail(itemScanList, widget.cart);
                  if (value.success) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: Colors.white),
                            SizedBox(width: 10),
                            Text("บันทึกสำเร็จ"),
                          ],
                        ),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                    navigator.pop();
                  } else {
                    if (mounted) setState(() => _isLoading = false);
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text(value.message), backgroundColor: Colors.red),
                    );
                  }
                } catch (error) {
                  if (mounted) setState(() => _isLoading = false);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('บันทึก', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
