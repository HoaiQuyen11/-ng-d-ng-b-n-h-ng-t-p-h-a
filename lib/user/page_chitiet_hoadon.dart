import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minimart/controller/controller_product.dart';
import 'package:minimart/model/chitietdonhang.dart';
import 'package:minimart/user/page_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:minimart/model/donhang.dart';


class PageChiTietHoaDon extends StatefulWidget {
  @override
  _PageChiTietHoaDonState createState() => _PageChiTietHoaDonState();
}

class _PageChiTietHoaDonState extends State<PageChiTietHoaDon> {
  final _formKey = GlobalKey<FormState>();
  final tenController = TextEditingController();
  final sdtController = TextEditingController();
  final diaChiController = TextEditingController();

  final controller = ControllerProduct.get();

  @override
  void initState() {
    super.initState();
    _loadKhachHangInfo();
  }

  Future<void> _loadKhachHangInfo() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('KhachHang')
        .select()
        .eq('uid', user.id) // sửa thành uid
        .maybeSingle();

    if (response != null) {
      setState(() {
        tenController.text = response['ten'] ?? '';
        sdtController.text = response['sodienthoai'] ?? '';
        diaChiController.text = response['diachi'] ?? '';
      });
    }
  }

  Future<void> _updateKhachHangInfo() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await Supabase.instance.client
        .from('KhachHang')
        .update({
      'ten': tenController.text,
      'sodienthoai': sdtController.text,
      'diachi': diaChiController.text,
    })
        .eq('uid', user.id); // sửa thành uid
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thông tin hóa đơn")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: tenController,
                    decoration: InputDecoration(labelText: "Tên"),
                    validator: (value) =>
                    value!.isEmpty ? "Vui lòng nhập tên" : null,
                  ),
                  TextFormField(
                    controller: sdtController,
                    decoration: InputDecoration(labelText: "Số điện thoại"),
                    validator: (value) =>
                    value!.isEmpty ? "Vui lòng nhập SĐT" : null,
                  ),
                  TextFormField(
                    controller: diaChiController,
                    decoration: InputDecoration(labelText: "Địa chỉ"),
                    validator: (value) =>
                    value!.isEmpty ? "Vui lòng nhập địa chỉ" : null,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: controller.GioHang.length,
                itemBuilder: (context, index) {
                  final item = controller.GioHang[index];
                  return ListTile(
                    title: Text(item.product.ten),
                    subtitle: Text("x${item.soLuong}"),
                    trailing: Text(
                      "${(item.product.gia ?? 0) * item.soLuong} VNĐ",
                      style: TextStyle(fontSize: 13),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text("Tổng cộng: ",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        "${controller.tongTien} VNĐ",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final user = Supabase.instance.client.auth.currentUser;
                        if (user == null) return;

                        // 1. Cập nhật thông tin khách hàng
                        await _updateKhachHangInfo();

                        // 2. Tạo đơn hàng
                        final donHang = DonHang(
                          uuid: user.id,
                          ten: tenController.text,
                          email: user.email ?? '',
                          sodienthoai: sdtController.text,
                          diachi: diaChiController.text,
                          tongtien: controller.tongTien,
                        );

                        final donHangId = await DonHangSnapshot.insert(donHang);
                        if (donHangId == null) {
                          Get.snackbar("Lỗi", "Không thể tạo đơn hàng");
                          return;
                        }

                        // 3. Tạo danh sách chi tiết đơn hàng
                        final chiTietList = controller.GioHang.map((item) {
                          final gia = item.product.gia ?? 0;
                          return ChiTietDonHang(
                            orderId: donHangId,
                            tenSp: item.product.ten,
                            soluong: item.soLuong,
                            giatien: gia,
                            thanhtien: gia * item.soLuong,
                          );
                        }).toList();

                        await ChiTietDonHangSnapshot.insertAll(chiTietList);

                        // 4. Xoá giỏ hàng và chuyển về trang chính
                        Get.defaultDialog(
                          title: "Thành công",
                          content: Text("Bạn đã đặt hàng thành công!"),
                          confirm: ElevatedButton(
                            onPressed: () {
                              controller.GioHang.clear();
                              Get.offAll(() => PageUser());
                            },
                            child: Text("OK"),
                          ),
                        );
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text("Đặt hàng",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
