import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PageProfile extends StatefulWidget {
  const PageProfile({super.key});

  @override
  State<PageProfile> createState() => _PageProfileState();
}

class _PageProfileState extends State<PageProfile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool hasData = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('KhachHang')
        .select()
        .eq('uid', user.id)
        .maybeSingle();

    if (response != null) {
      setState(() {
        nameController.text = response['ten'] ?? '';
        addressController.text = response['diachi'] ?? '';
        phoneController.text = response['sodienthoai'] ?? '';
        hasData = true;
      });
    }
  }

  Future<void> saveProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn chưa đăng nhập")),
      );
      return;
    }

    final name = nameController.text.trim();
    final address = addressController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || address.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }

    try {
      if (hasData) {
        // Cập nhật
        await Supabase.instance.client
            .from('KhachHang')
            .update({
          'ten': name,
          'diachi': address,
          'sodienthoai': phone,
        })
            .eq('uid', user.id);
      } else {
        // Thêm mới
        await Supabase.instance.client.from('KhachHang').insert({
          'uid': user.id,
          'email': user.email,
          'ten': name,
          'diachi': address,
          'sodienthoai': phone,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lưu thành công")),
      );

      Navigator.pop(context);
    } catch (e) {
      print("Lỗi khi lưu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lưu thất bại: $e")),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin cá nhân')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: saveProfile,
              child: Text(hasData ? 'Cập nhật' : 'Lưu mới'),
            ),
          ],
        ),
      ),
    );
  }
}
