import 'package:flutter/material.dart';
import 'package:mobilestock/model/permission_model.dart';
import 'package:mobilestock/repository/webservice_repository.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final WebServiceRepository _repo = WebServiceRepository();
  final TextEditingController _searchController = TextEditingController();

  List<PermissionModel> _users = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    await _repo.getUserPermissions(query).then((value) {
      if (value.success) {
        setState(() {
          _users = (value.data as List).map((e) => PermissionModel.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(value.message), backgroundColor: Colors.red),
          );
        }
      }
    }).catchError((error) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
        );
      }
    });
  }

  void _showEditDialog(PermissionModel user) {
    PermissionModel edited = user;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.admin_panel_settings_outlined, color: Colors.teal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(user.code, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPermissionTile(
                    label: 'แฮนเฮลด์',
                    icon: Icons.move_to_inbox_outlined,
                    color: Colors.purple,
                    value: edited.handheldList,
                    onChanged: (v) => setStateDialog(() => edited = edited.copyWith(handheldList: v)),
                  ),
                  _buildPermissionTile(
                    label: 'ขอโอนสินค้า',
                    icon: Icons.move_to_inbox_outlined,
                    color: const Color(0xFF3B82F6),
                    value: edited.requestList,
                    onChanged: (v) => setStateDialog(() => edited = edited.copyWith(requestList: v)),
                  ),
                  _buildPermissionTile(
                    label: 'โอนสินค้า',
                    icon: Icons.local_shipping_outlined,
                    color: const Color(0xFFEF4444),
                    value: edited.transferList,
                    onChanged: (v) => setStateDialog(() => edited = edited.copyWith(transferList: v)),
                  ),
                  _buildPermissionTile(
                    label: 'ตรวจนับสินค้า',
                    icon: Icons.fact_check_outlined,
                    color: const Color(0xFF10B981),
                    value: edited.stockList,
                    onChanged: (v) => setStateDialog(() => edited = edited.copyWith(stockList: v)),
                  ),
                  _buildPermissionTile(
                    label: 'ตรวจสอบสินค้าคงคลัง',
                    icon: Icons.inventory_2_outlined,
                    color: const Color(0xFFF59E0B),
                    value: edited.infoList,
                    onChanged: (v) => setStateDialog(() => edited = edited.copyWith(infoList: v)),
                  ),
                  _buildPermissionTile(
                    label: 'จัดการบาร์โค้ด',
                    icon: Icons.qr_code_scanner,
                    color: const Color(0xFF6366F1),
                    value: edited.barcodeList,
                    onChanged: (v) => setStateDialog(() => edited = edited.copyWith(barcodeList: v)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('ยกเลิก', style: TextStyle(color: Colors.grey.shade600)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await _savePermission(edited);
                },
                child: const Text('บันทึก', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPermissionTile({
    required String label,
    required IconData icon,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.teal,
            activeTrackColor: Colors.teal.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  Future<void> _savePermission(PermissionModel perm) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.teal)),
    );

    await _repo.updatePermission(
      usercode: perm.code,
      stockList: perm.stockList,
      requestList: perm.requestList,
      transferList: perm.transferList,
      handheldList: perm.handheldList,
      barcodeList: perm.barcodeList,
      infoList: perm.infoList,
    ).then((value) {
      if (mounted) Navigator.of(context).pop();
      if (value.success) {
        // อัพเดท list ในหน้า
        setState(() {
          final idx = _users.indexWhere((u) => u.code == perm.code);
          if (idx != -1) _users[idx] = perm;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('บันทึกสิทธิ์สำเร็จ'), backgroundColor: Colors.teal),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(value.message), backgroundColor: Colors.red),
          );
        }
      }
    }).catchError((error) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/menu');
            }
          },
        ),
        title: const Text('จัดการสิทธิ์ผู้ใช้', style: TextStyle(fontWeight: FontWeight.w600)),
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
                      hintText: 'ค้นหารหัสหรือชื่อผู้ใช้...',
                      prefixIcon: const Icon(Icons.search, color: Colors.teal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.teal),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('ค้นหา'),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                : !_hasSearched
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.manage_accounts_outlined, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text('ค้นหาผู้ใช้เพื่อจัดการสิทธิ์', style: TextStyle(color: Colors.grey.shade500)),
                          ],
                        ),
                      )
                    : _users.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_off_outlined, size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text('ไม่พบผู้ใช้', style: TextStyle(color: Colors.grey.shade500)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _users.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (_, index) {
                              final user = _users[index];
                              final permCount = [
                                user.handheldList, user.requestList, user.transferList,
                                user.stockList, user.infoList, user.barcodeList,
                              ].where((e) => e).length;

                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.teal.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.person_outline, color: Colors.teal),
                                  ),
                                  title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text(
                                    'รหัส: ${user.code}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: permCount > 0
                                              ? Colors.teal.withValues(alpha: 0.1)
                                              : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '$permCount/6',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: permCount > 0 ? Colors.teal : Colors.grey.shade500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.chevron_right, color: Colors.grey),
                                    ],
                                  ),
                                  onTap: () => _showEditDialog(user),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
