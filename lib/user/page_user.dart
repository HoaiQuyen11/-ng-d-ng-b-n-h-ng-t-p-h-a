import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minimart/controller/controller_product.dart';
import 'package:badges/badges.dart' as badges;
import 'package:minimart/model/model_product.dart' as Snapshot;

import 'package:minimart/page_home_login.dart';
import 'package:minimart/user/page_chitiet_product.dart';
import 'package:minimart/model/model_product.dart';
import 'package:minimart/user/page_giohang.dart';
import 'package:minimart/user/page_profile.dart';
import 'package:search_page/search_page.dart';

class PageUser extends StatefulWidget {
  const PageUser({super.key});

  @override
  State<PageUser> createState() => _PageUserState();
}

class _PageUserState extends State<PageUser> {
  int index=0;
  String selectedCategory = 'Tất cả';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MINI MART"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: GetBuilder<ControllerProduct>(
              id: "gh",
              init: ControllerProduct.get(),
              builder: (controller) {
                return badges.Badge(
                  position: badges.BadgePosition.topEnd(top: -5, end: -5),
                  showBadge: controller.slMHGH > 0,
                  badgeContent: Text(
                    '${controller.slMHGH}',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.deepOrange.shade50,
                    child: IconButton(
                      onPressed: () {
                        Get.to(() => PageGioHang());
                      },
                      icon: Icon(Icons.shopping_cart),
                      color: Colors.deepOrange,
                    ),
                  ),
                );
              },
            ),

          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(SupabaseHelper.response?.user != null
                  ? "Xin Chào"
                  : "Không rõ tên"),
              accountEmail: Text(SupabaseHelper.response?.user?.email ?? "Chưa đăng nhập"),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),

            // Nút Hồ sơ (Profile)
            if (SupabaseHelper.response?.user != null)
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text("Hồ sơ"),
                onTap: () {
                  Get.to(() => PageProfile());
                },
              ),

            // Nút Đăng xuất (Logout)
            if (SupabaseHelper.response?.user != null)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Đăng xuất"),
                onTap: () async {
                  await SupabaseHelper.client.auth.signOut();
                  Get.offAll(() => PageUser());
                },
              ),

            // Nút Đăng nhập (nếu chưa đăng nhập)
            if (SupabaseHelper.response?.user == null)
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text("Đăng nhập"),
                onTap: () {
                  Get.offAll(() => PageLogin());
                },
              ),

            const Divider(),
          ],
        ),
      ),



      body: SingleChildScrollView(
        child: Padding(padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cửa hàng tiện lợi uy tín nhất Nha Trang",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 20,),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 1,
                        blurRadius: 5,
                      )
                    ]
                ),

                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  tileColor: Colors.white,
                  leading: Icon(Icons.search, color: Colors.grey),
                  title: Text('Tìm kiếm sản phẩm'),
                  onTap: () {
                    showSearch(
                      context: context,
                      delegate: SearchPage<Product>(
                        items: Snapshot.data!,
                        searchLabel: 'Tìm kiếm theo tên',
                        suggestion: Center(child: Text('Nhập tên sản phẩm')),
                        failure: Center(child: Text('Không tìm thấy sản phẩm nào')),
                        filter: (product) => [product.ten.toLowerCase()],
                        builder: (product) => ListTile(
                          title: Text(product.ten),
                          onTap: () {
                            Get.back();
                            Get.to(() => PageChiTietProduct(product: product));
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20,),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    buildCategogyChip('Tất cả', selectedCategory == 'Tất cả'),
                    buildCategogyChip('Đồ ăn', selectedCategory == 'Đồ ăn'),
                    buildCategogyChip('Đồ uống', selectedCategory == 'Đồ uống'),
                    buildCategogyChip('Đồ gia dụng', selectedCategory == 'Đồ gia dụng'),
                  ],
                ),
              ),

              SizedBox(height: 20,),
              Text(
                selectedCategory,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15,),
              StreamBuilder<List<Product>>(
                stream: ProductSnapshot.getProductStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error.toString());
                    return Center(child: Text("Lỗi!!!"));
                  }
                  if (!snapshot.hasData) {
                    return Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          Text("Loading..."),
                        ],
                      ),
                    );
                  }

                  // Lọc theo loại
                  List<Product> allProducts = snapshot.data!;
                  List<Product> filtered = selectedCategory == 'Tất cả'
                      ? allProducts
                      : allProducts.where((p) => p.phanLoai == selectedCategory).toList();

                  return GridView.extent(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    maxCrossAxisExtent: 300,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75,
                    children: filtered.map((product) {
                      return GestureDetector(
                        onTap: () {
                          Get.to(PageChiTietProduct(product: product));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 5,
                                spreadRadius: 1,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                    image: DecorationImage(
                                      image: NetworkImage(product.anh ?? "no image"),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.ten, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      SizedBox(height: 4),
                                      Text("${product.gia} VNĐ", style: TextStyle(fontSize: 14, color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

            ],
          ),

        ),

      ),
    );
  }
  Widget buildCategogyChip(String label, bool isSelected) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedColor: Colors.deepOrange,
        onSelected: (selected) {
          setState(() {
            selectedCategory = label;
          });
        },
      ),
    );
  }
}






