import 'package:flutter/material.dart';
import 'package:minimart/admin/page_admin.dart';

class PageXemDonHang extends StatefulWidget {
  final Map<String, dynamic> donHang;
  final List<dynamic> chiTiet;
  const PageXemDonHang({super.key, required this.donHang, required this.chiTiet});

  @override
  State<PageXemDonHang> createState() => _PageXemDonhangState();
}

class _PageXemDonhangState extends State<PageXemDonHang> {
  List<Widget> chiTietWidgets() {
    List<Widget> widgets = [];
    for (var sp in widget.chiTiet) {
      widgets.add(
        Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(sp['ten_sp']),
            subtitle: Text('SL: ${sp['soluong']} x ${sp['giatien']}đ'),
            trailing: Text('${sp['thanhtien']}đ'),
          ),
        ),
      );
    }
    return widgets;
  }

  void _xacNhan() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xác nhận đơn hàng!')),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PageProductAdmin()),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    final donHang = widget.donHang;
    return Scaffold(
      appBar: AppBar(title: const Text('Thông Tin Đơn Hàng')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  const TextSpan(text: 'Tên khách hàng: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${donHang['ten']}'),
                ],
              ),
            ),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  const TextSpan(text: 'Email: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${donHang['email']}'),
                ],
              ),
            ),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  const TextSpan(text: 'Số điện thoại: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${donHang['sodienthoai']}'),
                ],
              ),
            ),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  const TextSpan(text: 'Địa chỉ: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${donHang['diachi']}'),
                ],
              ),
            ),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  const TextSpan(text: 'Ngày đặt: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${donHang['created_at'].toString().substring(0, 19)}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Chi tiết sản phẩm:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Column(
              children: chiTietWidgets(),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Tổng tiền: ${donHang['tongtien']}đ',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _xacNhan,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xác nhận', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
