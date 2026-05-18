import 'package:flutter/material.dart';
import 'package:mobilestock/model/price_permission_model.dart';
import 'package:mobilestock/repository/webservice_repository.dart';

class PricePermissionScreen extends StatefulWidget {
  const PricePermissionScreen({super.key});

  @override
  State<PricePermissionScreen> createState() => _PricePermissionScreenState();
}

class _PricePermissionScreenState extends State<PricePermissionScreen> {
  static const double _userColumnWidth = 220;
  static const double _priceColumnWidth = 120;
  static const double _rowContentWidth =
      _userColumnWidth + (_priceColumnWidth * 10);
  static const double _tableWidth = _rowContentWidth + 40;

  final WebServiceRepository _repo = WebServiceRepository();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final Set<String> _dirtyUsers = {};

  List<PricePermissionModel> _users = [];
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    setState(() {
      _isLoading = true;
      _dirtyUsers.clear();
    });

    await _repo.getUserPricePermissions(query).then((value) {
      if (value.success) {
        setState(() {
          _users = (value.data as List)
              .map((e) => PricePermissionModel.fromJson(e))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showError(value.message);
      }
    }).catchError((error) {
      setState(() => _isLoading = false);
      _showError(error.toString());
    });
  }

  Future<void> _save() async {
    if (_dirtyUsers.isEmpty) return;
    setState(() => _isSaving = true);

    try {
      for (final user
          in _users.where((user) => _dirtyUsers.contains(user.code))) {
        final result = await _repo.updatePricePermission(
            usercode: user.code, prices: user.prices);
        if (!result.success) {
          throw Exception(result.message);
        }
      }
      if (!mounted) return;
      setState(() {
        _dirtyUsers.clear();
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('บันทึกสิทธิ์ราคาสำเร็จ'),
            backgroundColor: Color(0xFF0F766E)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showError(error.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _toggleUserPrice(int userIndex, int priceIndex, bool value) {
    final user = _users[userIndex];
    final prices = List<bool>.from(user.prices);
    prices[priceIndex] = value;
    setState(() {
      _users[userIndex] = user.copyWith(prices: prices);
      _dirtyUsers.add(user.code);
    });
  }

  void _toggleColumn(int priceIndex, bool value) {
    setState(() {
      for (var i = 0; i < _users.length; i++) {
        final user = _users[i];
        final prices = List<bool>.from(user.prices);
        prices[priceIndex] = value;
        _users[i] = user.copyWith(prices: prices);
        _dirtyUsers.add(user.code);
      }
    });
  }

  void _toggleAll(bool value) {
    setState(() {
      for (var i = 0; i < _users.length; i++) {
        final user = _users[i];
        _users[i] = user.copyWith(prices: List<bool>.filled(10, value));
        _dirtyUsers.add(user.code);
      }
    });
  }

  bool _isColumnChecked(int priceIndex) {
    return _users.isNotEmpty && _users.every((user) => user.prices[priceIndex]);
  }

  bool get _isAllChecked {
    return _users.isNotEmpty && _users.every((user) => user.isAllChecked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text('กำหนดสิทธิ์ราคา',
            style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          TextButton.icon(
            onPressed: _isSaving || _dirtyUsers.isEmpty ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_outlined, color: Colors.white),
            label: Text(
              _dirtyUsers.isEmpty ? 'บันทึก' : 'บันทึก (${_dirtyUsers.length})',
              style: TextStyle(
                  color: _dirtyUsers.isEmpty ? Colors.white54 : Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ค้นหารหัสหรือชื่อพนักงาน...',
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFF0F766E)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF0F766E)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isLoading ? null : _search,
                  style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E)),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.search, color: Colors.white),
                  tooltip: 'ค้นหา',
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0F766E)))
                : _users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.manage_accounts_outlined,
                                size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text('ไม่พบพนักงาน',
                                style: TextStyle(color: Colors.grey.shade500)),
                          ],
                        ),
                      )
                    : _buildPermissionTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTable() {
    return Scrollbar(
      controller: _horizontalScrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        padding: const EdgeInsets.all(12),
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _tableWidth,
          child: Column(
            children: [
              _buildHeaderRow(),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: _users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) => _buildUserRow(index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _userColumnWidth,
            child: CheckboxListTile(
              value: _isAllChecked,
              onChanged: (value) => _toggleAll(value ?? false),
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('พนักงาน',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
          ...List.generate(10, (index) {
            return SizedBox(
              width: _priceColumnWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ราคา $index',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700)),
                  Checkbox(
                    value: _isColumnChecked(index),
                    onChanged: (value) => _toggleColumn(index, value ?? false),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUserRow(int index) {
    final user = _users[index];
    final isDirty = _dirtyUsers.contains(user.code);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isDirty ? const Color(0xFF0F766E) : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _userColumnWidth,
            child: ListTile(
              dense: true,
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF0F766E).withValues(alpha: 0.1),
                child: const Icon(Icons.person_outline,
                    color: Color(0xFF0F766E), size: 20),
              ),
              title: Text(user.name.isEmpty ? '-' : user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: Text(user.code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ),
          ),
          ...List.generate(10, (priceIndex) {
            return SizedBox(
              width: _priceColumnWidth,
              child: Checkbox(
                value: user.prices[priceIndex],
                onChanged: (value) =>
                    _toggleUserPrice(index, priceIndex, value ?? false),
              ),
            );
          }),
        ],
      ),
    );
  }
}
