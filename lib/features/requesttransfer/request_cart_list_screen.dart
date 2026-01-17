import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mobilestock/features/requesttransfer/request_cart_detail_screen.dart';
import 'package:mobilestock/features/requesttransfer/request_cart_form_screen.dart';
import 'package:mobilestock/features/requesttransfer/request_cart_merge_screen.dart';
import 'package:mobilestock/features/requesttransfer/request_cart_read_detail_screen.dart';
import 'package:mobilestock/model/cart_model.dart';
import 'package:mobilestock/repository/webservice_repository.dart';

class RequestCartListScreen extends StatefulWidget {
  const RequestCartListScreen({super.key});

  @override
  State<RequestCartListScreen> createState() => _RequestCartListScreenState();
}

class _RequestCartListScreenState extends State<RequestCartListScreen> {
  final WebServiceRepository _webServiceRepository = WebServiceRepository();
  List<CartModel> carts = [];
  List<bool> checked = [];
  bool showCheckbox = false;
  bool _isLoading = false;
  int transFlag = 1;

  @override
  void initState() {
    getCartList();
    super.initState();
  }

  void getCartList() async {
    setState(() {
      _isLoading = true;
    });

    await _webServiceRepository.getCartList(transFlag).then((value) {
      if (value.success) {
        setState(() {
          carts = (value.data as List).map((data) => CartModel.fromJson(data)).toList();
          checked = List<bool>.filled(carts.length, false);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }).onError((error, stackTrace) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  String formatTime(String timeString) {
    try {
      final time = DateTime.parse("1970-01-01 $timeString");
      return DateFormat('HH:mm').format(time);
    } catch (e) {
      return timeString;
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
          'ตะกร้าขอโอนสินค้า',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (showCheckbox)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  showCheckbox = false;
                  checked = List<bool>.filled(carts.length, false);
                });
              },
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              label: const Text('ยกเลิก', style: TextStyle(color: Colors.white)),
            )
          else
            IconButton(
              onPressed: _isLoading ? null : () => getCartList(),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.refresh),
              tooltip: 'รีเฟรช',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.add_circle_outline,
                      label: 'สร้างตะกร้าใหม่',
                      color: const Color(0xFF3B82F6),
                      onPressed: () {
                        final res = Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RequestCartFormScreen(cart: CartModel(docno: '')),
                          ),
                        );
                        res.then((value) {
                          getCartList();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: showCheckbox ? Icons.check_circle : Icons.compare_arrows,
                      label: showCheckbox ? 'เลือก ${checked.where((e) => e).length} รายการ' : 'รวมตะกร้า',
                      color: const Color(0xFFF59E0B),
                      onPressed: () {
                        setState(() {
                          showCheckbox = !showCheckbox;
                          if (!showCheckbox) {
                            checked = List<bool>.filled(carts.length, false);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Cart List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF10B981)),
                          SizedBox(height: 16),
                          Text('กำลังโหลด...', style: TextStyle(color: Color(0xFF64748B))),
                        ],
                      ),
                    )
                  : carts.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () async => getCartList(),
                          color: const Color(0xFF10B981),
                          child: ListView.separated(
                            padding: const EdgeInsets.all(6),
                            itemCount: carts.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 7),
                            itemBuilder: (context, index) {
                              return _buildCartCard(carts[index], index);
                            },
                          ),
                        ),
            ),

            // Merge Bottom Sheet
            if (showCheckbox && checked.where((e) => e).isNotEmpty) _buildMergeBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'ยังไม่มีตะกร้าขอโอนสินค้า',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'กดปุ่ม "สร้างตะกร้าใหม่" เพื่อเริ่มต้น',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartCard(CartModel cart, int index) {
    final isMerged = cart.ismerge == 1;
    final hasSubCarts = cart.carts.isNotEmpty;

    Color cardColor;
    Color accentColor;
    IconData statusIcon;
    String statusText;

    if (isMerged) {
      cardColor = const Color(0xFF10B981).withOpacity(0.05);
      accentColor = const Color(0xFF10B981);
      statusIcon = Icons.merge_type;
      statusText = 'ตะกร้ารวมแล้ว';
    } else if (hasSubCarts) {
      cardColor = const Color(0xFF3B82F6).withOpacity(0.05);
      accentColor = const Color(0xFF3B82F6);
      statusIcon = Icons.account_tree_outlined;
      statusText = 'ตะกร้ารวม';
    } else {
      cardColor = Colors.white;
      accentColor = const Color(0xFF64748B);
      statusIcon = Icons.shopping_cart_outlined;
      statusText = 'ปกติ';
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: showCheckbox && checked[index] ? Border.all(color: const Color(0xFF10B981), width: 2) : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: showCheckbox
              ? () {
                  setState(() {
                    checked[index] = !checked[index];
                  });
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    if (showCheckbox) ...[
                      Checkbox(
                        value: checked[index],
                        onChanged: (value) {
                          setState(() {
                            checked[index] = value!;
                          });
                        },
                        activeColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(statusIcon, color: accentColor, size: 20),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  cart.docno,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // if (hasSubCarts && !isMerged) ...[
                              //   const SizedBox(width: 8),
                              //   Container(
                              //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              //     decoration: BoxDecoration(
                              //       color: accentColor.withOpacity(0.1),
                              //       borderRadius: BorderRadius.circular(6),
                              //     ),
                              //     child: Text(
                              //       statusText,
                              //       style: TextStyle(
                              //         fontSize: 10,
                              //         fontWeight: FontWeight.w600,
                              //         color: accentColor,
                              //       ),
                              //     ),
                              //   ),
                              // ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${cart.docdate} • ${formatTime(cart.doctime)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${cart.itemcount} รายการ',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                // Details
                _buildDetailRow(Icons.warehouse_outlined, 'คลัง', '${cart.whcode} - ${cart.whname}'),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.location_on_outlined, 'ที่เก็บ', '${cart.locationcode} - ${cart.locationname}'),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.warehouse_outlined, 'คลังปลายทาง', '${cart.whto} - ${cart.whtoname}'),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.location_on_outlined, 'ที่เก็บปลายทาง', '${cart.locationto} - ${cart.locationtoname}'),
                const SizedBox(height: 8),

                if (cart.creatorname.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.person_outline, 'ผู้สร้าง', cart.creatorname),
                ],
                if (cart.remark.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.note_outlined, 'หมายเหตุ', cart.remark),
                ],

                // แสดงตะกร้าย่อย (ถ้าเป็นตะกร้ารวม)
                if (cart.carts.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildSubCartsSection(cart, statusText),
                ], // Action Buttons
                if (!showCheckbox) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (!isMerged) ...[
                        _buildIconButton(
                          icon: Icons.send_outlined,
                          color: const Color(0xFF10B981),
                          tooltip: 'ส่ง',
                          onPressed: () {
                            if (cart.itemcount > 0) {
                              _showConfirmSendDialog(context, cart);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("ไม่มีสินค้าในตะกร้า"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                        _buildIconButton(
                          icon: Icons.edit_outlined,
                          color: const Color(0xFFF59E0B),
                          tooltip: 'แก้ไข',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RequestCartFormScreen(cart: cart),
                              ),
                            ).then((value) {
                              getCartList();
                            });
                          },
                        ),
                      ],
                      _buildIconButton(
                        icon: Icons.qr_code_scanner_outlined,
                        color: const Color(0xFF3B82F6),
                        tooltip: 'สแกน',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RequestCartDetailScreen(cart: cart, ismerge: cart.ismerge),
                            ),
                          ).then((value) {
                            getCartList();
                          });
                        },
                      ),
                      if (!isMerged) ...[
                        _buildIconButton(
                          icon: Icons.delete_outline,
                          color: const Color(0xFFEF4444),
                          tooltip: 'ลบ',
                          onPressed: () {
                            _showConfirmationDialog(context, cart.docno);
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1E293B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSubCartsSection(CartModel cart, String statusText) {
    // แยกเลขที่ตะกร้าย่อยจาก string
    final subCartNumbers = cart.carts.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return Material(
      color: const Color(0xFF3B82F6).withOpacity(0.05),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => _showSubCartsBottomSheet(subCartNumbers, statusText),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_tree_outlined, size: 18, color: Color(0xFF3B82F6)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'กดเพื่อดูรายการ ${subCartNumbers.length} ตะกร้า',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${subCartNumbers.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Color(0xFF3B82F6), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubCartsBottomSheet(List<String> subCartNumbers, String statusText) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SubCartsBottomSheet(
        subCartNumbers: subCartNumbers,
        statusText: statusText,
        onCartSelected: _openSubCartDetail,
      ),
    );
  }

  void _openSubCartDetail(String docno) async {
    // แสดง loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
      ),
    ); // ดึงข้อมูลตะกร้าจาก API
    await _webServiceRepository.getCartDetail(docno).then((value) {
      Navigator.pop(context); // ปิด loading

      if (value.success) {
        // สร้าง CartModel จากข้อมูล
        final cart = carts.firstWhere(
          (c) => c.docno == docno,
          orElse: () => CartModel(docno: docno),
        );

        // ไปหน้ารายละเอียด (อ่านอย่างเดียว)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestCartReadDetailScreen(
              cart: cart,
              ismerge: 1, // โหมดอ่านอย่างเดียว
            ),
          ),
        ).then((value) {
          getCartList();
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
      Navigator.pop(context); // ปิด loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                tooltip,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMergeBottomBar() {
    final selectedCount = checked.where((e) => e).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected items preview
            if (selectedCount > 0)
              Builder(
                builder: (context) {
                  final selectedCarts = <CartModel>[];
                  for (int i = 0; i < checked.length; i++) {
                    if (checked[i]) selectedCarts.add(carts[i]);
                  } // ตรวจสอบว่าคลังและที่เก็บตรงกันหรือไม่
                  final isSameWarehouseLocation = selectedCarts.length < 2 || selectedCarts.every((cart) => cart.whcode == selectedCarts.first.whcode && cart.locationcode == selectedCarts.first.locationcode);

                  // ตรวจสอบว่าคลังปลายทางและที่เก็บปลายทางตรงกันหรือไม่
                  final isSameWarehouseLocationTo = selectedCarts.length < 2 || selectedCarts.every((cart) => cart.whto == selectedCarts.first.whto && cart.locationto == selectedCarts.first.locationto);

                  // รวมเงื่อนไขทั้งหมด
                  final canMerge = isSameWarehouseLocation && isSameWarehouseLocationTo;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: canMerge ? const Color(0xFF10B981).withOpacity(0.05) : const Color(0xFFF59E0B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: !canMerge ? Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5)) : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ตะกร้าที่เลือก',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$selectedCount รายการ',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ), // แสดงคำเตือนถ้าคลัง/ที่เก็บไม่ตรงกัน
                        if (!isSameWarehouseLocation) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'คลังหรือที่เก็บไม่ตรงกัน ไม่สามารถรวมตะกร้าได้',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFB45309),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // แสดงคำเตือนถ้าคลังปลายทาง/ที่เก็บปลายทางไม่ตรงกัน
                        if (!isSameWarehouseLocationTo) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'คลังปลายทางหรือที่เก็บปลายทางไม่ตรงกัน ไม่สามารถรวมตะกร้าได้',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFB45309),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        // แสดงรายการตะกร้าที่เลือกพร้อมคลัง/ที่เก็บ/คลังปลายทาง/ที่เก็บปลายทาง
                        ...selectedCarts.map((cart) {
                          final isFirstCart = cart == selectedCarts.first;
                          final matchesFirst = cart.whcode == selectedCarts.first.whcode && cart.locationcode == selectedCarts.first.locationcode && cart.whto == selectedCarts.first.whto && cart.locationto == selectedCarts.first.locationto;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: matchesFirst || isFirstCart ? const Color(0xFF10B981).withOpacity(0.3) : const Color(0xFFF59E0B).withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                if (!matchesFirst && !isFirstCart)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 6),
                                    child: Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 14),
                                  ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cart.docno,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: matchesFirst || isFirstCart ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${cart.whcode}-${cart.locationcode} → ${cart.whto}-${cart.locationto}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),

            // Merge Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedCount >= 2 ? const Color(0xFF10B981) : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: selectedCount >= 2
                    ? () {
                        // ตรวจสอบว่าตะกร้าที่เลือกมีคลังและที่เก็บเดียวกันหรือไม่
                        final selectedCarts = carts.where((element) => checked[carts.indexOf(element)]).toList();
                        final firstCart = selectedCarts.first;
                        final isSameWarehouseLocation = selectedCarts.every(
                          (cart) => cart.whcode == firstCart.whcode && cart.locationcode == firstCart.locationcode,
                        );

                        // ตรวจสอบว่าคลังปลายทางและที่เก็บปลายทางตรงกันหรือไม่
                        final isSameWarehouseLocationTo = selectedCarts.every(
                          (cart) => cart.whto == firstCart.whto && cart.locationto == firstCart.locationto,
                        );

                        if (!isSameWarehouseLocation) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text("ไม่สามารถรวมตะกร้าได้\nกรุณาเลือกตะกร้าที่มีคลังและที่เก็บเดียวกัน"),
                                  ),
                                ],
                              ),
                              backgroundColor: Color(0xFFF59E0B),
                              duration: Duration(seconds: 3),
                            ),
                          );
                          return;
                        }

                        if (!isSameWarehouseLocationTo) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text("ไม่สามารถรวมตะกร้าได้\nกรุณาเลือกตะกร้าที่มีคลังปลายทางและที่เก็บปลายทางเดียวกัน"),
                                  ),
                                ],
                              ),
                              backgroundColor: Color(0xFFF59E0B),
                              duration: Duration(seconds: 3),
                            ),
                          );
                          return;
                        }

                        showCheckbox = false;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RequestCartMergeScreen(
                              cart: selectedCarts,
                            ),
                          ),
                        ).then((value) {
                          checked = [];
                          getCartList();
                        });
                      }
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(selectedCount == 1 ? "กรุณาเลือกมากกว่า 1 ตะกร้า" : "กรุณาเลือกตะกร้า"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                icon: const Icon(Icons.merge_type, color: Colors.white),
                label: Text(
                  selectedCount >= 2 ? 'รวมตะกร้า ($selectedCount)' : 'เลือกอย่างน้อย 2 ตะกร้า',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showConfirmSendDialog(BuildContext context, CartModel cart) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

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
                child: const Icon(Icons.send_outlined, color: Color(0xFF10B981)),
              ),
              const SizedBox(width: 12),
              const Text('ยืนยันการส่ง', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Text('คุณต้องการส่งตะกร้า ${cart.docno} ใช่หรือไม่?'),
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก', style: TextStyle(color: Colors.grey.shade600)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('ยืนยัน', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // ปิด confirm dialog ก่อน

                await _webServiceRepository.SaveRequestTransfer(cart).then((value) {
                  if (value.success) {
                    final docref = value.data['docref'] ?? '';
                    getCartList();
                    // แสดง dialog แจ้งเลข docref
                    if (mounted) {
                      _showSuccessDialog(context, docref);
                    }
                  } else {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(value.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }).onError((error, stackTrace) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(error.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String docref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF10B981),
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'ส่งตะกร้าสำเร็จ!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'เลขที่เอกสารขอโอนสินค้า',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                  ),
                ),
                child: SelectableText(
                  docref,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3B82F6),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'ตกลง',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _showConfirmationDialog(BuildContext context, String docno) {
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
                child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
              ),
              const SizedBox(width: 12),
              const Text('ยืนยันการลบ', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Text('คุณต้องการลบตะกร้า $docno ใช่หรือไม่?'),
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก', style: TextStyle(color: Colors.grey.shade600)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('ยืนยัน', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await _webServiceRepository.deleteCart(docno).then((value) {
                  if (value.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("ลบตะกร้าสำเร็จ"),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                    getCartList();
                    Navigator.of(context).pop();
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
              },
            ),
          ],
        );
      },
    );
  }
}

// Bottom Sheet สำหขอโอนแสดงรายการตะกร้าย่อย
class _SubCartsBottomSheet extends StatelessWidget {
  final List<String> subCartNumbers;
  final String statusText;
  final Function(String) onCartSelected;

  const _SubCartsBottomSheet({
    required this.subCartNumbers,
    required this.statusText,
    required this.onCartSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_tree_outlined, color: Color(0xFF3B82F6), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'เลือกตะกร้าเพื่อดูรายละเอียด',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${subCartNumbers.length} ตะกร้า',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // List
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: subCartNumbers.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final docno = subCartNumbers[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    docno,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  subtitle: const Text(
                    'กดเพื่อดูรายละเอียดสินค้า',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF3B82F6)),
                  ),
                  onTap: () {
                    Navigator.pop(context); // ปิด bottom sheet
                    onCartSelected(docno);
                  },
                );
              },
            ),
          ),

          // ปุ่มปิด
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'ปิด',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
