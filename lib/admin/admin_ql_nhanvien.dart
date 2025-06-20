import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minimart/admin/admin_add_nhanvien.dart';
import 'package:minimart/model/model_ql_nhanvien.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:minimart/helper/supabase_helper.dart';

class AdminQlNhanvien extends StatefulWidget {
  const AdminQlNhanvien({super.key});

  @override
  State<AdminQlNhanvien> createState() => _AdminQlNhanvienState();
}

class _AdminQlNhanvienState extends State<AdminQlNhanvien> {
  final RxList<Employee> _employees = <Employee>[].obs;
  final RxBool _isLoading = true.obs;
  final RxString _errorMessage = ''.obs;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    _isLoading.value = true;
    _errorMessage.value = '';
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('employees')
          .select('*')
          .order('name', ascending: true);

      _employees.value = response.map((json) => Employee.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      _errorMessage.value = 'Lỗi Postgrest: ${e.message}';
    } catch (e) {
      _errorMessage.value = 'Đã xảy ra lỗi: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _deleteEmployee(int id, String name) async {
    final confirm = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xoá"),
        content: Text("Bạn có chắc muốn xoá nhân viên \"$name\"?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Huỷ")),
          TextButton(onPressed: () => Navigator.pop(context, "ok"), child: const Text("Xoá")),
        ],
      ),
    );

    if (confirm == "ok") {
      try {
        await supabase.from('employees').delete().eq('id', id);
        _fetchEmployees();
        Get.snackbar("Thành công", "Đã xoá nhân viên $name", snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar("Lỗi", "Không thể xoá nhân viên", snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFDADA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFDADA),
        title: const Text("Quản lý nhân viên"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchEmployees,
          ),
        ],
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_errorMessage.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _fetchEmployees,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        if (_employees.isEmpty) {
          return const Center(child: Text("Không có nhân viên nào."));
        }

        return ListView.builder(
          itemCount: _employees.length,
          itemBuilder: (context, index) {
            final employee = _employees[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              elevation: 1,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueGrey.shade100,
                  backgroundImage: employee.avatar != null && employee.avatar!.isNotEmpty
                      ? NetworkImage(employee.avatar!)
                      : null,
                  child: (employee.avatar == null || employee.avatar!.isEmpty)
                      ? Text(employee.name[0].toUpperCase())
                      : null,
                ),
                title: Text(
                  employee.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ca làm: ${employee.shift}'),
                    if (employee.email != null && employee.email!.isNotEmpty)
                      Text('Email: ${employee.email}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Get.snackbar("Chỉnh sửa", "Bạn chọn chỉnh sửa ${employee.name}",
                            snackPosition: SnackPosition.BOTTOM);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteEmployee(employee.id, employee.name),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PageAddNhanVien()),
          ).then((_) => _fetchEmployees());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
