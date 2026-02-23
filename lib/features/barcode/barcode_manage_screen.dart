import 'package:flutter/material.dart';
import 'package:mobilestock/repository/webservice_repository.dart';

class BarcodeManageScreen extends StatefulWidget {
  const BarcodeManageScreen({super.key});

  @override
  State<BarcodeManageScreen> createState() => _BarcodeManageScreenState();
}

class _BarcodeManageScreenState extends State<BarcodeManageScreen> {
  final WebServiceRepository _repo = WebServiceRepository();
  final TextEditingController _searchController = TextEditingController();

  bool _isSearching = false;
  List<Map<String, dynamic>> _inventoryList = [];

  Map<String, dynamic>? _selectedItem;
  List<Map<String, dynamic>> _barcodeList = [];
  bool _isLoadingBarcodes = false;

  Future<void> _searchInventory(String search) async {
    if (search.trim().isEmpty) return;
    setState(() {
      _isSearching = true;
      _inventoryList = [];
    });

    try {
      final result = await _repo.getInventoryMaster(search.trim());
      if (!mounted) return;
      if (result.success) {
        setState(() {
          _inventoryList = (result.data as List).map((e) => Map<String, dynamic>.from(e)).toList();
        });
      } else {
        _showSnackBar(result.message, isError: true);
      }
    } catch (e) {
      if (mounted) _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _loadBarcodes(String itemCode) async {
    setState(() {
      _isLoadingBarcodes = true;
      _barcodeList = [];
    });

    try {
      final result = await _repo.getBarcodeMaster(itemCode);
      if (!mounted) return;
      if (result.success) {
        setState(() {
          _barcodeList = (result.data as List).map((e) => Map<String, dynamic>.from(e)).toList();
        });
      } else {
        _showSnackBar(result.message, isError: true);
      }
    } catch (e) {
      if (mounted) _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoadingBarcodes = false);
    }
  }

  void _selectItem(Map<String, dynamic> item) {
    setState(() {
      _selectedItem = item;
      _inventoryList = [];
      _searchController.clear();
    });
    _loadBarcodes(item['item_code']);
  }

  void _showEditBarcodeDialog(Map<String, dynamic> bc) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: _EditBarcodeDialog(
          bc: bc,
          repo: _repo,
          onSaved: () => _loadBarcodes(_selectedItem!['item_code']),
        ),
      ),
    );
  }

  void _showAddBarcodeSheet() {
    if (_selectedItem == null) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: _AddBarcodeSheet(
          item: _selectedItem!,
          repo: _repo,
          onSaved: () => _loadBarcodes(_selectedItem!['item_code']),
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF10B981),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        title: const Text('จัดการบาร์โค้ด', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ค้นหาสินค้า (รหัส/ชื่อ)...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Color(0xFF6366F1))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: _searchInventory,
                    textInputAction: TextInputAction.search,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      elevation: 0,
                    ),
                    onPressed: _isSearching ? null : () => _searchInventory(_searchController.text),
                    child: _isSearching ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Inventory search results (full screen when searching)
          if (_inventoryList.isNotEmpty)
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView.separated(
                  itemCount: _inventoryList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final item = _inventoryList[index];
                    return ListTile(
                      dense: true,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF6366F1), size: 18),
                      ),
                      title: Text(item['item_name'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      subtitle: Text(item['item_code'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      onTap: () => _selectItem(item),
                    );
                  },
                ),
              ),
            ),

          // Selected Item Card (hidden while showing search results)
          if (_inventoryList.isEmpty && _selectedItem != null)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedItem!['item_name'] ?? '',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'รหัส: ${_selectedItem!['item_code']}  |  หน่วย: ${_selectedItem!['unit_standard'] ?? ''}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedItem = null;
                        _barcodeList = [];
                      });
                    },
                    icon: Icon(Icons.close, color: Colors.grey.shade500, size: 20),
                  ),
                ],
              ),
            ),

          // Barcode List Header
          if (_inventoryList.isEmpty && _selectedItem != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'รายการบาร์โค้ด',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      elevation: 0,
                    ),
                    onPressed: _showAddBarcodeSheet,
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text('เพิ่มบาร์โค้ด', style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ],
              ),
            ),

          // Barcode List
          if (_inventoryList.isEmpty)
            Expanded(
              child: _selectedItem == null
                  ? _buildEmptyState()
                  : _isLoadingBarcodes
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                      : _barcodeList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.qr_code_2, size: 64, color: Colors.grey.shade300),
                                  const SizedBox(height: 12),
                                  Text('ยังไม่มีบาร์โค้ด', style: TextStyle(color: Colors.grey.shade500)),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              itemCount: _barcodeList.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final bc = _barcodeList[index];
                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                    boxShadow: [
                                      BoxShadow(color: Colors.grey.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.qr_code, color: Color(0xFF10B981), size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              bc['barcode'] ?? '-',
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                            ),
                                            const SizedBox(height: 4),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 4,
                                              children: [
                                                _chip('หน่วย: ${bc['unit_code'] ?? '-'}', const Color(0xFF3B82F6)),
                                                _chip('ราคา: ${bc['price'] ?? '-'}', const Color(0xFF10B981)),
                                                _chip('สมาชิก: ${bc['price_member'] ?? '-'}', const Color(0xFFF59E0B)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _showEditBarcodeDialog(bc),
                                        icon: const Icon(Icons.edit_outlined, color: Color(0xFF6366F1), size: 20),
                                        tooltip: 'แก้ไข',
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('ค้นหาสินค้าเพื่อจัดการบาร์โค้ด', style: TextStyle(fontSize: 15, color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          Text('พิมพ์รหัสหรือชื่อสินค้า แล้วกด Enter', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}

// Dialog แก้ไขบาร์โค้ด
class _EditBarcodeDialog extends StatefulWidget {
  final Map<String, dynamic> bc;
  final WebServiceRepository repo;
  final VoidCallback onSaved;

  const _EditBarcodeDialog({required this.bc, required this.repo, required this.onSaved});

  @override
  State<_EditBarcodeDialog> createState() => _EditBarcodeDialogState();
}

class _EditBarcodeDialogState extends State<_EditBarcodeDialog> {
  late final TextEditingController _priceController;
  late final TextEditingController _priceMemberController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: widget.bc['price']?.toString() ?? '');
    _priceMemberController = TextEditingController(text: widget.bc['price_member']?.toString() ?? '');
  }

  @override
  void dispose() {
    _priceController.dispose();
    _priceMemberController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_priceController.text.trim().isEmpty) {
      _showSnackBar('กรุณากรอกราคา', isError: true);
      return;
    }

    final confirmed = await _showConfirmDialog();
    if (!confirmed || !mounted) return;

    setState(() => _isSaving = true);
    try {
      final result = await widget.repo.updateBarcode(
        barcode: widget.bc['barcode'],
        price: _priceController.text.trim(),
        priceMember: _priceMemberController.text.trim().isEmpty ? _priceController.text.trim() : _priceMemberController.text.trim(),
      );
      if (!mounted) return;
      if (result.success) {
        widget.onSaved();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('แก้ไขบาร์โค้ดสำเร็จ'), backgroundColor: Color(0xFF10B981)),
        );
      } else {
        _showSnackBar(result.message, isError: true);
      }
    } catch (e) {
      if (mounted) _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.edit_outlined, color: Color(0xFF6366F1)),
                SizedBox(width: 10),
                Text('ยืนยันการแก้ไข', style: TextStyle(fontSize: 17)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _confirmRow('บาร์โค้ด', widget.bc['barcode'] ?? ''),
                _confirmRow('ราคา', _priceController.text.trim()),
                _confirmRow('ราคาสมาชิก', _priceMemberController.text.trim().isEmpty ? _priceController.text.trim() : _priceMemberController.text.trim()),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('ยกเลิก', style: TextStyle(color: Colors.grey.shade600)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('ยืนยัน', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _confirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text('$label:', style: TextStyle(fontSize: 13, color: Colors.grey.shade600))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)))),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red : const Color(0xFF10B981)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit_outlined, color: Color(0xFF6366F1), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('แก้ไขบาร์โค้ด', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        Text(widget.bc['barcode'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                    tooltip: 'ปิด',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barcode (readonly)
                  _label('บาร์โค้ด'),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(widget.bc['barcode'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                  ),
                  const SizedBox(height: 16),

                  // Price
                  _label('ราคา *'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'กรอกราคา',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFF6366F1))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price member
                  _label('ราคาสมาชิก'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _priceMemberController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'กรอกราคาสมาชิก (ถ้าเว้นว่างจะใช้ราคาเดียวกับราคาปกติ)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFF6366F1))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: _isSaving ? null : _save,
                      icon: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save_outlined, color: Colors.white),
                      label: Text(_isSaving ? 'กำลังบันทึก...' : 'บันทึก', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700));
  }
}

// Bottom Sheet เพิ่มบาร์โค้ด
class _AddBarcodeSheet extends StatefulWidget {
  final Map<String, dynamic> item;
  final WebServiceRepository repo;
  final VoidCallback onSaved;

  const _AddBarcodeSheet({required this.item, required this.repo, required this.onSaved});

  @override
  State<_AddBarcodeSheet> createState() => _AddBarcodeSheetState();
}

class _AddBarcodeSheetState extends State<_AddBarcodeSheet> {
  final _barcodeController = TextEditingController();
  final _priceController = TextEditingController();
  final _priceMemberController = TextEditingController();
  final _barcodeFocusNode = FocusNode();

  bool _isCheckingBarcode = false;
  bool _barcodeValid = false;
  String? _barcodeError;

  List<Map<String, dynamic>> _unitList = [];
  Map<String, dynamic>? _selectedUnit;
  bool _isLoadingUnits = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUnits();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _barcodeFocusNode.requestFocus();
    });
  }

  Future<void> _loadUnits() async {
    setState(() => _isLoadingUnits = true);
    try {
      final result = await widget.repo.getUnitMaster(widget.item['item_code']);
      if (!mounted) return;
      if (result.success) {
        setState(() {
          _unitList = (result.data as List).map((e) => Map<String, dynamic>.from(e)).toList();
          if (_unitList.isNotEmpty) _selectedUnit = _unitList.first;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingUnits = false);
  }

  Future<void> _checkBarcode(String barcode) async {
    if (barcode.trim().isEmpty) return;
    setState(() {
      _isCheckingBarcode = true;
      _barcodeValid = false;
      _barcodeError = null;
    });
    try {
      final result = await widget.repo.checkBarcodeExists(barcode.trim());
      if (!mounted) return;
      if (result.success) {
        final existx = result.data['existx'] ?? false;
        setState(() {
          _barcodeValid = !existx;
          _barcodeError = existx ? 'บาร์โค้ดนี้มีอยู่ในระบบแล้ว' : null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _barcodeError = e.toString());
    } finally {
      if (mounted) setState(() => _isCheckingBarcode = false);
    }
  }

  Future<void> _save() async {
    if (!_barcodeValid) {
      _showSnackBar('กรุณาตรวจสอบบาร์โค้ดก่อน', isError: true);
      return;
    }
    if (_selectedUnit == null) {
      _showSnackBar('กรุณาเลือกหน่วยนับ', isError: true);
      return;
    }
    if (_priceController.text.trim().isEmpty) {
      _showSnackBar('กรุณากรอกราคา', isError: true);
      return;
    }

    final confirmed = await _showConfirmDialog();
    if (!confirmed || !mounted) return;

    setState(() => _isSaving = true);
    try {
      final result = await widget.repo.createNewBarcode(
        itemCode: widget.item['item_code'],
        itemName: widget.item['item_name'],
        barcode: _barcodeController.text.trim(),
        unitCode: _selectedUnit!['code'],
        price: _priceController.text.trim(),
        priceMember: _priceMemberController.text.trim().isEmpty ? _priceController.text.trim() : _priceMemberController.text.trim(),
      );
      if (!mounted) return;
      if (result.success) {
        widget.onSaved();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกบาร์โค้ดสำเร็จ'), backgroundColor: Color(0xFF10B981)),
        );
      } else {
        _showSnackBar(result.message, isError: true);
      }
    } catch (e) {
      if (mounted) _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.qr_code_scanner, color: Color(0xFF6366F1)),
                SizedBox(width: 10),
                Text('ยืนยันการบันทึก', style: TextStyle(fontSize: 17)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _confirmRow('สินค้า', widget.item['item_name'] ?? ''),
                _confirmRow('บาร์โค้ด', _barcodeController.text.trim()),
                _confirmRow('หน่วยนับ', _selectedUnit?['name'] ?? ''),
                _confirmRow('ราคา', _priceController.text.trim()),
                _confirmRow('ราคาสมาชิก', _priceMemberController.text.trim().isEmpty ? _priceController.text.trim() : _priceMemberController.text.trim()),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('ยกเลิก', style: TextStyle(color: Colors.grey.shade600)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('ยืนยัน', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _confirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text('$label:', style: TextStyle(fontSize: 13, color: Colors.grey.shade600))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)))),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red : const Color(0xFF10B981)),
    );
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _priceController.dispose();
    _priceMemberController.dispose();
    _barcodeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.qr_code_scanner, color: Color(0xFF6366F1), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('เพิ่มบาร์โค้ด', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        Text(widget.item['item_name'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                    tooltip: 'ปิด',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barcode field
                  _label('บาร์โค้ด *'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _barcodeController,
                          focusNode: _barcodeFocusNode,
                          decoration: InputDecoration(
                            hintText: 'กรอกบาร์โค้ด',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                            focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFF6366F1))),
                            errorText: _barcodeError,
                            suffixIcon: _barcodeValid ? const Icon(Icons.check_circle, color: Color(0xFF10B981)) : null,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          keyboardType: TextInputType.number,
                          onSubmitted: _checkBarcode,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          elevation: 0,
                        ),
                        onPressed: _isCheckingBarcode ? null : () => _checkBarcode(_barcodeController.text),
                        child: _isCheckingBarcode ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('ตรวจสอบ', style: TextStyle(color: Colors.white, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Unit selection
                  _label('หน่วยนับ *'),
                  const SizedBox(height: 6),
                  _isLoadingUnits
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                      : DropdownButtonFormField<Map<String, dynamic>>(
                          initialValue: _selectedUnit,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: _unitList
                              .map((unit) => DropdownMenuItem<Map<String, dynamic>>(
                                    value: unit,
                                    child: Text('${unit['name']} (x${unit['ratio']})'),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedUnit = val),
                        ),
                  const SizedBox(height: 16),

                  // Price
                  _label('ราคา *'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'กรอกราคา',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFF6366F1))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price member
                  _label('ราคาสมาชิก'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _priceMemberController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'กรอกราคาสมาชิก (ถ้าเว้นว่างจะใช้ราคาเดียวกับราคาปกติ)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFF6366F1))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: _isSaving ? null : _save,
                      icon: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save_outlined, color: Colors.white),
                      label: Text(_isSaving ? 'กำลังบันทึก...' : 'บันทึก', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700));
  }
}
