import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobilestock/model/cart_model.dart';
import 'package:mobilestock/model/warehouse_location.dart';
import 'package:mobilestock/repository/webservice_repository.dart';
import 'package:mobilestock/global.dart' as global;

class HandheldMergeScreen extends StatefulWidget {
  final List<CartModel> cart;
  const HandheldMergeScreen({super.key, required this.cart});

  @override
  State<HandheldMergeScreen> createState() => _HandheldMergeScreenState();
}

class _HandheldMergeScreenState extends State<HandheldMergeScreen> {
  // Theme Colors
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color bgColor = Color(0xFFF8FAFC);

  final TextEditingController basketNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  WarehouseModel selectedWarehouse = WarehouseModel();
  LocationModel selectedLocation = LocationModel();

  final WebServiceRepository _webServiceRepository = WebServiceRepository();
  List<WarehouseModel> warehouses = [];
  List<LocationModel> locations = [];
  TextEditingController remarkController = TextEditingController();
  bool _isLoading = false;
  int transFlag = 4;
  // วันที่และเวลา
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();

    if (widget.cart.isNotEmpty) {
      basketNumberController.text = generateBasketNumber();
      selectedWarehouse = WarehouseModel(code: widget.cart[0].whcode, name: widget.cart[0].whname);

      // โหลดวันที่เวลาจาก cart แรก
      if (widget.cart[0].docdate.isNotEmpty) {
        try {
          selectedDate = DateFormat('yyyy-MM-dd').parse(widget.cart[0].docdate);
        } catch (e) {
          selectedDate = DateTime.now();
        }
      }
      if (widget.cart[0].doctime.isNotEmpty) {
        try {
          final timeParts = widget.cart[0].doctime.split(':');
          selectedTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        } catch (e) {
          selectedTime = TimeOfDay.now();
        }
      }

      remarkController.text = widget.cart[0].remark;
      Future.delayed(const Duration(milliseconds: 300), () async {
        getLocation();
      });
    }
  }

  void getLocation() async {
    setState(() => _isLoading = true);
    await _webServiceRepository.getLocation(selectedWarehouse.code).then((value) {
      if (value.success) {
        setState(() {
          locations = (value.data as List).map((data) => LocationModel.fromJson(data)).toList();
          if (widget.cart[0].docno.isNotEmpty) {
            selectedLocation = LocationModel(code: widget.cart[0].locationcode, name: widget.cart[0].locationname);
          }
        });
      } else {
        _showSnackBar(value.message, isError: true);
      }
    }).onError((error, stackTrace) {
      _showSnackBar(error.toString(), isError: true);
    }).whenComplete(() {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _showSnackBar(String message, {bool isError = false, bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : (isSuccess ? Icons.check_circle_outline : Icons.info_outline),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? errorRed : (isSuccess ? successGreen : primaryBlue),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
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
              primary: primaryBlue,
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
      setState(() => selectedDate = picked);
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
              primary: primaryBlue,
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
      setState(() => selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        title: const Text(
          'รวมตะกร้า',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryBlue),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Header Card
                    _buildHeaderCard(),
                    const SizedBox(height: 16),

                    // วันที่และเวลา Card
                    _buildDateTimeCard(),
                    const SizedBox(height: 16),

                    // คลังและที่เก็บ Card
                    _buildWarehouseLocationCard(),
                    const SizedBox(height: 16),

                    // ตะกร้าที่เลือก Card
                    _buildSelectedCartsCard(),
                    const SizedBox(height: 16),

                    // หมายเหตุ Card
                    _buildRemarkCard(),
                    const SizedBox(height: 24),

                    // ปุ่มสร้างตะกร้า
                    _buildMergeButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryBlue, Color(0xFF60A5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.merge, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'เลขที่ตะกร้ารวม',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      basketNumberController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_outline, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  'ผู้สร้าง: ${global.userCode}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: warningOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_today, color: warningOrange, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'วันที่และเวลาตรวจนับ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateTimeField(
                  label: 'วันที่',
                  value: DateFormat('dd/MM/yyyy').format(selectedDate),
                  icon: Icons.calendar_month,
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateTimeField(
                  label: 'เวลา',
                  value: '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  icon: Icons.access_time,
                  onTap: _selectTime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryBlue, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit, color: Color(0xFFCBD5E1), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warehouse, color: successGreen, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'คลังและที่เก็บ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // คลัง (Read only - แสดงจาก cart ที่เลือก)
          _buildInfoField(
            label: 'คลัง',
            value: selectedWarehouse.code.isNotEmpty ? '${selectedWarehouse.code} - ${selectedWarehouse.name}' : 'ไม่ระบุ',
            icon: Icons.inventory_2_outlined,
          ),
          const SizedBox(height: 12),

          // ที่เก็บ (Read only - แสดงจาก cart ที่เลือก)
          _buildInfoField(
            label: 'ที่เก็บ',
            value: selectedLocation.code.isNotEmpty ? '${selectedLocation.code} - ${selectedLocation.name}' : 'ไม่ระบุ',
            icon: Icons.location_on_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline, color: Color(0xFFCBD5E1), size: 16),
        ],
      ),
    );
  }

  Widget _buildLocationDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: Color(0xFF64748B), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ที่เก็บ',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<LocationModel>(
                    value: locations.any((loc) => loc.code == selectedLocation.code) ? locations.firstWhere((loc) => loc.code == selectedLocation.code) : null,
                    hint: const Text(
                      'เลือกที่เก็บ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    isExpanded: true,
                    isDense: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: primaryBlue),
                    items: locations.map((LocationModel location) {
                      return DropdownMenuItem<LocationModel>(
                        value: location,
                        child: Text(
                          '${location.code} - ${location.name}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (LocationModel? val) {
                      if (val != null) {
                        setState(() => selectedLocation = val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCartsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shopping_cart, color: primaryBlue, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'ตะกร้าที่เลือกรวม',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.cart.length} ตะกร้า',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.cart.map((cart) => _buildCartItem(cart)),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartModel cart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.check, color: successGreen, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              cart.docno,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Text(
            cart.docdate,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarkCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF64748B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.note_alt_outlined, color: Color(0xFF64748B), size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'หมายเหตุ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: remarkController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'เพิ่มหมายเหตุ (ถ้ามี)',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              filled: true,
              fillColor: bgColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryBlue, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMergeButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: successGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
          shadowColor: successGreen.withOpacity(0.4),
        ),
        onPressed: _isLoading ? null : _mergeCart,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.merge, size: 22),
            const SizedBox(width: 10),
            const Text(
              'สร้างตะกร้ารวม',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _mergeCart() async {
    if (selectedWarehouse.code.isEmpty || selectedLocation.code.isEmpty) {
      _showSnackBar('กรุณาเลือกคลังและที่เก็บ', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    var cartsarr = widget.cart.map((e) => e.docno).toList();
    String result = cartsarr.join(',');

    String docdate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String doctime = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

    await _webServiceRepository.mergeCart(basketNumberController.text, docdate, doctime, selectedWarehouse.code, selectedLocation.code, remarkController.text, result, '', transFlag).then((value) {
      if (value.success) {
        _showSnackBar('สร้างตะกร้ารวมสำเร็จ', isSuccess: true);
        Navigator.of(context).pop("success");
      } else {
        _showSnackBar(value.message, isError: true);
      }
    }).onError((error, stackTrace) {
      _showSnackBar(error.toString(), isError: true);
    }).whenComplete(() {
      if (mounted) setState(() => _isLoading = false);
    });
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
    return 'HL$year$month$day$hour$minute$randomDigits';
  }
}
