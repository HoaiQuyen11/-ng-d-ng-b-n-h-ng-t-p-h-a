import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:badges/badges.dart' as badges;
import 'package:get/get.dart';
import 'package:minimart/model/model_product.dart';
import 'package:minimart/page_home_login.dart';
import 'package:minimart/user/page_giohang.dart';
import 'package:minimart/controller/controller_product.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';


class PageChiTietProduct extends StatefulWidget {
  final Product product;
  PageChiTietProduct({super.key, required this.product});

  @override
  State<PageChiTietProduct> createState() => _PageChiTietProductState();
}

class _PageChiTietProductState extends State<PageChiTietProduct> {
  int soLuong = 1;

  @override
  Widget build(BuildContext context) {
    double rating = getRating();
    Product product = widget.product;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.ten,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          GestureDetector(
            onTap: () {
              Get.to(() => PageGioHang());
            },
            child: GetBuilder(
              id: "gh",
              init: ControllerProduct.get(),
              builder: (controller) => badges.Badge(
                showBadge: controller.slMHGH>0,
                badgeContent: Text('${controller.slMHGH}', style: TextStyle(color: Colors.white),),
                child: Icon(Icons.shopping_cart, size: 30,),
              ),
            ),
          ),
          SizedBox(width: 20,),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: Image.network(product.anh ?? "Link anh mac dinh", fit: BoxFit.fitWidth,),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "${product.gia ?? 0} VNĐ",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "${(product.gia ?? 0) * 1.2} VNĐ",
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Nút trừ
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (soLuong > 1) soLuong--;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(5),
                                child: Icon(Icons.remove, color: Colors.blueAccent),
                              ),
                            ),

                            SizedBox(width: 14),

                            // Số lượng
                            Text(
                              soLuong.toString().padLeft(1, '0'),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),

                            SizedBox(width: 14),

                            // Nút cộng
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  soLuong++;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(5),
                                child: Icon(Icons.add, color: Colors.blueAccent),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      product.ten,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      product.moTa ?? "",
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: rating,
                          itemBuilder: (context, index) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 30.0,
                          direction: Axis.horizontal,
                        ),

                        Text("$rating", style: TextStyle(color: Colors.red),),
                        SizedBox(width: 20,),
                        Expanded(child: Text("${Random().nextInt(1000)+1} đánh giá")),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final user = Supabase.instance.client.auth.currentUser;

          if (user == null) {
            Get.to(() => PageLogin());
          } else {
            // Thêm vào giỏ cục bộ
            for (int i = 0; i < soLuong; i++) {
              ControllerProduct.get().themMHGH(widget.product);
            }

            final supabase = Supabase.instance.client;

            try {
              // Kiểm tra sản phẩm đã có trong giỏ chưa
              final res = await supabase
                  .from('GioHang')
                  .select()
                  .eq('idkhachhang', user.id)
                  .eq('idproduct', widget.product.id)
                  .maybeSingle();

              if (res != null) {
                // Nếu đã có → cập nhật số lượng
                final int soluongHienTai = res['soluong'] ?? 0;
                await supabase
                    .from('GioHang')
                    .update({'soluong': soluongHienTai + soLuong})
                    .match({
                  'idkhachhang': user.id,
                  'idproduct': widget.product.id,
                });
              } else {
                // Nếu chưa có → thêm mới
                await supabase.from('GioHang').insert({
                  'idkhachhang': user.id,
                  'idproduct': widget.product.id,
                  'soluong': soLuong,
                  'email': user.email,
                });
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã thêm vào giỏ hàng")),
              );
            } catch (e) {
              print('Lỗi Supabase: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Lỗi khi thêm/cập nhật giỏ hàng")),
              );
            }

            ControllerProduct.get().auth();
          }
        },


        label: const Text(
          "Thêm vào giỏ hàng",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add_shopping_cart),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
    );
  }
}

double getRating(){
  return Random().nextInt(201)/100 + 3;
}