import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobilestock/model/cart_model.dart';
import 'package:mobilestock/model/warehouse_location.dart';
import 'package:mobilestock/repository/webservice_repository.dart';
import 'package:mobilestock/global.dart' as global;

class CartFormScreen extends StatefulWidget {
  final CartModel cart;
  const CartFormScreen({super.key, required this.cart});

  @override
  State<CartFormScreen> createState() => _CartFormScreenState();
}

class _CartFormScreenState extends State<CartFormScreen> {
  final TextEditingController basketNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  WarehouseModel selectedWarehouse = WarehouseModel();
  LocationModel selectedLocation = LocationModel();

  final WebServiceRepository _webServiceRepository = WebServiceRepository();
  List<WarehouseModel> warehouses = [];
  List<LocationModel> locations = [];
  TextEditingController remarkController = TextEditingController();
  bool _isLoading = false;

  // วันที่และเวลา
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  int transflag = 0;
  @override
  void initState() {
    super.initState();
    getWareHouse();
    if (widget.cart.docno.isNotEmpty) {
      basketNumberController.text = widget.cart.docno;
      selectedWarehouse = WarehouseModel(code: widget.cart.whcode, name: widget.cart.whname);
      remarkController.text = widget.cart.remark;

      // โหลดวันที่เวลาจาก cart
      if (widget.cart.docdate.isNotEmpty) {
        try {
          selectedDate = DateFormat('yyyy-MM-dd').parse(widget.cart.docdate);
        } catch (e) {
          selectedDate = DateTime.now();
        }
      }
      if (widget.cart.doctime.isNotEmpty) {
        try {
          final timeParts = widget.cart.doctime.split(':');
          selectedTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        } catch (e) {
          selectedTime = TimeOfDay.now();
        }
      }

      Future.delayed(const Duration(milliseconds: 300), () async {
        getLocation();
      });
    } else {
      basketNumberController.text = generateBasketNumber();
      // default เป็นวันที่เวลาปัจจุบัน
      selectedDate = DateTime.now();
      selectedTime = TimeOfDay.now();
    }
  }

  void getWareHouse() async {
    await _webServiceRepository.getWarehouse().then((value) {
      if (value.success) {
        setState(() {
          warehouses = (value.data as List).map((data) => WarehouseModel.fromJson(data)).toList();
        });
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

  void getLocation() async {
    await _webServiceRepository.getLocation(selectedWarehouse.code).then((value) {
      if (value.success) {
        setState(() {
          locations = (value.data as List).map((data) => LocationModel.fromJson(data)).toList();
          if (widget.cart.docno.isNotEmpty) {
            selectedLocation = LocationModel(code: widget.cart.locationcode, name: widget.cart.locationname);
          }
        });
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
  Widget build(BuildContext context) {
    final isEdit = widget.cart.docno.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEdit ? 'แก้ไขตะกร้าตรวจนับ' : 'สร้างตะกร้าตรวจนับ',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card
            Container(
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isEdit ? Icons.edit_outlined : Icons.add_shopping_cart_outlined,
                      color: const Color(0xFF10B981),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? 'แก้ไขข้อมูลตะกร้า' : 'สร้างตะกร้าใหม่',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'กรอกข้อมูลด้านล่างให้ครบถ้วน',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // เลขที่ตะกร้า
                    _buildSectionTitle('เลขที่ตะกร้า', Icons.tag),
                    const SizedBox(height: 8),
                    _buildInputCard(
                      child: TextFormField(
                        controller: basketNumberController,
                        decoration: InputDecoration(
                          hintText: 'เลขที่ตะกร้า',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.qr_code_2, color: Colors.grey.shade400),
                          suffixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Auto',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        readOnly: true,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // คลัง
                    _buildSectionTitle('คลังสินค้า', Icons.warehouse_outlined),
                    const SizedBox(height: 8),
                    _buildSelectorField(
                      label: 'คลังสินค้า',
                      value: selectedWarehouse.code.isNotEmpty ? "${selectedWarehouse.code} - ${selectedWarehouse.name}" : null,
                      hint: 'เลือกคลังสินค้า',
                      icon: Icons.warehouse_outlined,
                      onTap: _showWarehouseSelector,
                    ),

                    const SizedBox(height: 20),

                    // ที่เก็บ
                    _buildSectionTitle('ที่เก็บสินค้า', Icons.location_on_outlined),
                    const SizedBox(height: 8),
                    _buildSelectorField(
                      label: 'ที่เก็บสินค้า',
                      value: selectedLocation.code.isNotEmpty ? "${selectedLocation.code} - ${selectedLocation.name}" : null,
                      hint: selectedWarehouse.code.isEmpty
                          ? "กรุณาเลือกคลังก่อน"
                          : locations.isEmpty
                              ? "กำลังโหลด..."
                              : "เลือกที่เก็บสินค้า",
                      icon: Icons.location_on_outlined,
                      onTap: _showLocationSelector,
                      enabled: selectedWarehouse.code.isNotEmpty,
                    ),
                    const SizedBox(height: 20),

                    // วันที่และเวลา
                    _buildSectionTitle('วันที่และเวลา', Icons.calendar_today_outlined),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // วันที่
                        Expanded(
                          child: _buildDateTimeField(
                            label: 'วันที่',
                            value: DateFormat('dd/MM/yyyy').format(selectedDate),
                            icon: Icons.calendar_today_outlined,
                            onTap: _selectDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // เวลา
                        Expanded(
                          child: _buildDateTimeField(
                            label: 'เวลา',
                            value: '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            icon: Icons.access_time_outlined,
                            onTap: _selectTime,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // หมายเหตุ
                    _buildSectionTitle('หมายเหตุ', Icons.note_outlined),
                    const SizedBox(height: 8),
                    _buildInputCard(
                      child: TextFormField(
                        controller: remarkController,
                        decoration: InputDecoration(
                          hintText: 'ระบุหมายเหตุ (ถ้ามี)',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(bottom: 50),
                            child: Icon(Icons.note_outlined, color: Colors.grey.shade400),
                          ),
                        ),
                        maxLines: 3,
                        style: const TextStyle(color: Color(0xFF1E293B)),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : _saveCart,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isEdit ? Icons.save_outlined : Icons.add_circle_outline,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isEdit ? 'บันทึกการแก้ไข' : 'สร้างตะกร้า',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard({required Widget child, bool enabled = true}) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade100,
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
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: child,
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF3B82F6),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_outlined,
              color: Colors.grey.shade400,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _showWarehouseSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WarehouseLocationSelector<WarehouseModel>(
        title: 'เลือกคลังสินค้า',
        icon: Icons.warehouse_outlined,
        items: warehouses,
        selectedItem: selectedWarehouse.code.isNotEmpty ? selectedWarehouse : null,
        itemBuilder: (item) => _SelectorItemData(
          code: item.code,
          name: item.name,
          icon: Icons.warehouse_outlined,
        ),
        onSelected: (item) {
          setState(() {
            selectedWarehouse = item;
            locations = [];
            selectedLocation = LocationModel();
          });
          Future.delayed(const Duration(milliseconds: 300), () {
            getLocation();
          });
        },
        searchFilter: (item, query) {
          final lowerQuery = query.toLowerCase();
          return item.code.toLowerCase().contains(lowerQuery) || item.name.toLowerCase().contains(lowerQuery);
        },
      ),
    );
  }

  void _showLocationSelector() {
    if (selectedWarehouse.code.isEmpty || locations.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WarehouseLocationSelector<LocationModel>(
        title: 'เลือกที่เก็บสินค้า',
        icon: Icons.location_on_outlined,
        items: locations,
        selectedItem: selectedLocation.code.isNotEmpty ? selectedLocation : null,
        itemBuilder: (item) => _SelectorItemData(
          code: item.code,
          name: item.name,
          icon: Icons.location_on_outlined,
        ),
        onSelected: (item) {
          setState(() {
            selectedLocation = item;
          });
        },
        searchFilter: (item, query) {
          final lowerQuery = query.toLowerCase();
          return item.code.toLowerCase().contains(lowerQuery) || item.name.toLowerCase().contains(lowerQuery);
        },
      ),
    );
  }

  Widget _buildSelectorField({
    required String label,
    required String? value,
    required String hint,
    required IconData icon,
    required VoidCallback? onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey.shade100,
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: enabled ? const Color(0xFF3B82F6).withOpacity(0.1) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: enabled ? const Color(0xFF3B82F6) : Colors.grey.shade400,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value ?? hint,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: value != null ? FontWeight.w600 : FontWeight.w400,
                      color: value != null ? const Color(0xFF1E293B) : Colors.grey.shade400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: enabled ? Colors.grey.shade400 : Colors.grey.shade300,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCart() async {
    if (selectedWarehouse.code.isEmpty || selectedLocation.code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text("กรุณาเลือกคลังและที่เก็บ"),
            ],
          ),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      // สร้าง docdate และ doctime
      final docdate = DateFormat('yyyy-MM-dd').format(selectedDate);
      final doctime = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00';

      if (widget.cart.docno.isEmpty) {
        // Create new cart
        final value = await _webServiceRepository.createCart(
          basketNumberController.text,
          selectedWarehouse.code,
          selectedLocation.code,
          remarkController.text,
          docdate,
          doctime,
          '',
          transflag,
        );

        if (value.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 10),
                  Text("สร้างตะกร้าสำเร็จ"),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          Navigator.of(context).pop("success");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(value.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Update cart
        final value = await _webServiceRepository.updateCart(
          basketNumberController.text,
          selectedWarehouse.code,
          selectedLocation.code,
          remarkController.text,
          docdate,
          doctime,
          '',
        );

        if (value.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 10),
                  Text("แก้ไขตะกร้าสำเร็จ"),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          Navigator.of(context).pop("success");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(value.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String generateBasketNumber() {
    var now = DateTime.now();
    var random = Random();
    String year = now.year.toString().padLeft(4, '0');
    String month = now.month.toString().padLeft(2, '0');
    String day = now.day.toString().padLeft(2, '0');
    String hour = now.hour.toString().padLeft(2, '0');
    String minute = now.minute.toString().padLeft(2, '0');
    String randomDigits = (random.nextInt(9000) + 1000).toString();
    return 'SC$year$month$day$hour$minute$randomDigits';
  }
}

// Helper class for selector item data
class _SelectorItemData {
  final String code;
  final String name;
  final IconData icon;

  _SelectorItemData({
    required this.code,
    required this.name,
    required this.icon,
  });
}

// Custom bottom sheet selector widget
class _WarehouseLocationSelector<T> extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<T> items;
  final T? selectedItem;
  final _SelectorItemData Function(T) itemBuilder;
  final void Function(T) onSelected;
  final bool Function(T, String) searchFilter;

  const _WarehouseLocationSelector({
    required this.title,
    required this.icon,
    required this.items,
    required this.selectedItem,
    required this.itemBuilder,
    required this.onSelected,
    required this.searchFilter,
  });

  @override
  State<_WarehouseLocationSelector<T>> createState() => _WarehouseLocationSelectorState<T>();
}

class _WarehouseLocationSelectorState<T> extends State<_WarehouseLocationSelector<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) => widget.searchFilter(item, query)).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.75),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon,
                    color: const Color(0xFF3B82F6),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        '${widget.items.length} รายการ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey.shade600,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'ค้นหา...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                          icon: Icon(Icons.clear, color: Colors.grey.shade400, size: 20),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Divider
          Divider(color: Colors.grey.shade200, height: 1),

          // List
          Flexible(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'ไม่พบข้อมูล',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final itemData = widget.itemBuilder(item);
                      final isSelected = widget.selectedItem == item;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            widget.onSelected(item);
                            Navigator.pop(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.08) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected ? Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)) : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.15) : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    itemData.icon,
                                    color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade500,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        itemData.code,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        itemData.name,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF475569),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF3B82F6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Safe area bottom
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
