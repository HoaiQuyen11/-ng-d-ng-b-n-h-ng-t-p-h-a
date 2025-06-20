import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minimart/controller/controller_product.dart';
import 'package:minimart/user/page_chitiet_hoadon.dart';
import 'package:minimart/user/page_user.dart';

class PageGioHang extends StatelessWidget {
  final ControllerProduct controller = ControllerProduct.get();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Giỏ hàng"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GetBuilder<ControllerProduct>(
        id: "gh",
        builder: (controller) {
          if (controller.GioHang.isEmpty) {
            return Center(child: Text("Giỏ hàng đang trống."));
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    ...controller.GioHang.map((item) => Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Image.network(item.product.anh ?? "", width: 60, height: 60, fit: BoxFit.cover),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.ten, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text("${item.product.gia} đồng", style: TextStyle(fontSize: 16)),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove),
                                        onPressed: () => controller.giamSoLuong(item),
                                      ),
                                      Text("${item.soLuong}"),
                                      IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: () => controller.tangSoLuong(item),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "${(item.product.gia ?? 0) * item.soLuong} VNĐ",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    )).toList(),

                    // Nút thêm sản phẩm
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            Get.to(() => PageUser());
                          },
                          icon: Icon(Icons.add_circle, color: Colors.blue, size: 28),
                          label: Text(
                            "Thêm sản phẩm",
                            style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
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
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      onPressed: () {
                        Get.to(() => PageChiTietHoaDon());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text("Xác nhận", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10)
            ],
          );

        },
      ),
    );
  }
}
