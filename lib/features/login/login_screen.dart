import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobilestock/bloc/authentication/authentication_bloc.dart';
import 'package:mobilestock/global.dart' as global;
import 'package:mobilestock/model/warehouse_location.dart';
import 'package:mobilestock/repository/webservice_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _searchController = TextEditingController();

  final WebServiceRepository _webServiceRepository = WebServiceRepository();
  List<WarehouseModel> branchList = [];
  List<WarehouseModel> filteredBranchList = [];
  bool showBranchSelect = false;

  @override
  void initState() {
    global.loadConfig();
    _usernameController.text = "";
    _passwordController.text = "";

    super.initState();
  }

  void _login() {
    if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      if (global.serverProvider.isEmpty || global.serverDatabase.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("กรุณาตั้งค่า Server ก่อน"),
          ),
        );
        return;
      }
      BlocProvider.of<AuthenticationBloc>(context).add(AuthenticationLoggedIn(
        _usernameController.text,
        _passwordController.text,
        global.serverProvider,
        global.serverDatabase,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("กรุณากรอกข้อมูลให้ครบถ้วน"),
        ),
      );
    }
  }

  void getCartList() async {
    await _webServiceRepository.getBranchList().then((value) {
      if (value.success) {
        final list = (value.data as List).map((data) => WarehouseModel.fromJson(data)).toList();

        // ถ้าไม่มีสาขา หรือมีสาขาเดียว ให้ข้ามไปหน้า menu เลย
        if (list.isEmpty) {
          Navigator.of(context).pushNamedAndRemoveUntil('/menu', (route) => false);
          return;
        }

        if (list.length == 1) {
          // มีสาขาเดียว เลือกอัตโนมัติ
          _selectBranch(list[0]);
          return;
        }

        setState(() {
          branchList = list;
          filteredBranchList = list;
          showBranchSelect = true;
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

  void _selectBranch(WarehouseModel branch) async {
    await global.saveConfigToPrefs(
      branchcode: branch.code,
      branchname: branch.name,
    );
    Navigator.of(context).pushNamedAndRemoveUntil('/menu', (route) => false);
  }

  void _filterBranches(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredBranchList = branchList;
      } else {
        filteredBranchList = branchList.where((branch) {
          return branch.name.toLowerCase().contains(query.toLowerCase()) || branch.code.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _openServerSettings() {
    Navigator.of(context).pushNamed('/config');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Color(0xFF2563EB),
                content: Text('เข้าสู่ระบบเรียบร้อยแล้ว'),
              ),
            );
            getCartList();
            setState(() {
              showBranchSelect = true;
            });
          } else if (state is AuthenticationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red.shade400,
                content: Text(state.message),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: (!showBranchSelect)
              ? SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const SizedBox(height: 60),
                          // Logo Section
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/logo/logonextstep.png',
                                height: 130,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 130,
                                    width: 130,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.inventory_2_outlined,
                                      size: 60,
                                      color: Color(0xFF3B82F6),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          Text(
                            'เข้าสู่ระบบเพื่อจัดการสต็อกสินค้า',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          // Username Field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'รหัสผู้ใช้',
                                labelStyle: TextStyle(color: Colors.grey.shade500),
                                prefixIcon: Icon(Icons.person_outline, color: const Color(0xFF3B82F6)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Password Field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'รหัสผ่าน',
                                labelStyle: TextStyle(color: Colors.grey.shade500),
                                prefixIcon: Icon(Icons.lock_outline, color: const Color(0xFF3B82F6)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Login Button
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3B82F6).withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _login,
                              child: const Text(
                                'เข้าสู่ระบบ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Settings Button
                          TextButton.icon(
                            onPressed: _openServerSettings,
                            icon: Icon(Icons.settings_outlined, color: Colors.grey.shade500, size: 20),
                            label: Text(
                              'ตั้งค่าเซิร์ฟเวอร์',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.store_outlined,
                                color: Color(0xFF3B82F6),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'เลือกสาขา',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                Text(
                                  'กรุณาเลือกสาขาที่ต้องการ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Search Box
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _filterBranches,
                            decoration: InputDecoration(
                              hintText: 'ค้นหาสาขา...',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear, color: Colors.grey.shade400),
                                      onPressed: () {
                                        _searchController.clear();
                                        _filterBranches('');
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Divider(color: Colors.grey.shade200, height: 1),
                      Expanded(
                        child: filteredBranchList.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
                                    const SizedBox(height: 16),
                                    Text(
                                      'ไม่พบสาขาที่ค้นหา',
                                      style: TextStyle(color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: filteredBranchList.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  return Container(
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
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      leading: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3B82F6).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.business_outlined,
                                          color: Color(0xFF3B82F6),
                                        ),
                                      ),
                                      title: Text(
                                        filteredBranchList[index].name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      subtitle: Text(
                                        filteredBranchList[index].code,
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 13,
                                        ),
                                      ),
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Color(0xFF94A3B8),
                                      ),
                                      onTap: () => _selectBranch(filteredBranchList[index]),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
        ));
  }
}
