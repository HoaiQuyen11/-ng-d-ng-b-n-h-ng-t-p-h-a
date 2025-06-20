import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:minimart/admin/admin_ql_nhanvien.dart';
import 'package:minimart/admin/page_chitiet_donhang.dart';
import 'package:minimart/controller/controller_product.dart';
import 'package:minimart/page_home_login.dart';
import 'package:minimart/user/page_user.dart';
import 'package:search_page/search_page.dart';
import '../helper/async_widget.dart';
import '../helper/dialogs.dart';
import 'package:minimart/helper/supabase_helper.dart';
import '../model/model_product.dart';
import '../model/model_product.dart' as Snapshot;
import '../user/page_chitiet_product.dart';
import 'admin_add.dart';
import 'admin_upload.dart';

class PageProductAdmin extends StatefulWidget {
  const PageProductAdmin({super.key});

  @override
  State<PageProductAdmin> createState() => _PageProductAdminState();
}

class _PageProductAdminState extends State<PageProductAdmin> {
  late BuildContext myContext;
  String selectedCategory = 'Tất cả';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý sản phẩm"),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orangeAccent.shade700,
              ),
              accountName: Text(
                SupabaseHelper.response?.user?.userMetadata?['full_name'] ?? "Admin",
              ),
              accountEmail: Text(
                SupabaseHelper.response?.user?.email ?? "Chưa đăng nhập",
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: SupabaseHelper.response?.user?.userMetadata?['avatar_url'] != null
                    ? NetworkImage(SupabaseHelper.response!.user!.userMetadata!['avatar_url'])
                    : const AssetImage("assets/image/avataradmin.jpg") as ImageProvider,
              ),
            ),

            // Các tùy chọn quản lý
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Quản lý nhân viên"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AdminQlNhanvien()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text("Quản lý sale"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PageProductAdmin()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text("Quản lý hóa đơn"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) =>PageChiTietDonHang()),
                );
              },
            ),
            const Spacer(),
            // Nút Đăng nhập hoặc Đăng xuất
            if (SupabaseHelper.response?.user == null)
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text("Đăng nhập"),
                onTap: () {
                  Get.offAll(() => PageLogin());
                },
              ),
            if (SupabaseHelper.response?.user != null)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Đăng xuất"),
                onTap: () async {
                  await SupabaseHelper.client.auth.signOut();
                  Get.offAll(() => PageUser());
                },
              ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ô tìm kiếm (chưa xử lý logic tìm kiếm)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 1,
                      blurRadius: 5,
                    )
                  ],
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  tileColor: Colors.white,
                  leading: const Icon(Icons.search, color: Colors.grey),
                  title: const Text('Tìm kiếm sản phẩm'),
                  onTap: () {
                    showSearch(
                      context: context,
                      delegate: SearchPage<Product>(
                        items: Snapshot.data!, // Ensure Snapshot.data! is populated with all products
                        searchLabel: 'Tìm kiếm theo tên',
                        suggestion: const Center(child: Text('Nhập tên sản phẩm')),
                        failure: const Center(child: Text('Không tìm thấy sản phẩm nào')),
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
              const SizedBox(height: 20),

              // Chip lọc sản phẩm
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    buildCategoryChip('Tất cả', selectedCategory == 'Tất cả'),
                    buildCategoryChip('Đồ ăn', selectedCategory == 'Đồ ăn'),
                    buildCategoryChip('Đồ uống', selectedCategory == 'Đồ uống'),
                    buildCategoryChip('Đồ gia dụng', selectedCategory == 'Đồ gia dụng'),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text(
                selectedCategory,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // Danh sách sản phẩm
              StreamBuilder<List<Product>>(
                stream: ProductSnapshot.getProductStream(),
                builder: (context, snapshot) {
                  return AsyncWidget(
                    snapshot: snapshot,
                    builder: (context, snapshot) {
                      var allProducts = snapshot.data!;
                      List<Product> filteredProducts = selectedCategory == 'Tất cả'
                          ? allProducts
                          : allProducts.where((p) => p.phanLoai == selectedCategory).toList();

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredProducts.length,
                        separatorBuilder: (context, index) => const Divider(thickness: 1.5),
                        itemBuilder: (context, index) {
                          myContext = context;
                          Product product = filteredProducts[index];

                          return Slidable(
                            key: ValueKey(product.id),
                            endActionPane: ActionPane(
                              extentRatio: 0.6,
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  flex: 3,
                                  onPressed: (context) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => PageUpdateProduct(product: product),
                                      ),
                                    );
                                  },
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  label: 'Cập nhật',
                                ),
                                SlidableAction(
                                  flex: 2,
                                  onPressed: (context) async {
                                    var xacNhan = await showConfirmDialog(
                                      myContext,
                                      "Bạn có muốn xóa ${product.ten}?",
                                    );
                                    if (xacNhan == "ok") {
                                      await ProductSnapshot.delete(product.id);
                                      ScaffoldMessenger.of(myContext)
                                        ..clearSnackBars()
                                        ..showSnackBar(SnackBar(
                                          content: Text("Đã xóa ${product.ten}"),
                                          duration: const Duration(seconds: 3),
                                        ));
                                    }
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete_forever,
                                  label: 'Xoá',
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Image.network(
                                    product.anh ?? "no image",
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Text("${product.id}", style: const TextStyle(fontSize: 20)),
                                      Text(
                                        "${product.ten}",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "${product.gia} đ",
                                        style: const TextStyle(fontSize: 20, color: Colors.red),
                                      ),
                                      Text(
                                        "${product.moTa}",
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PageAddProduct()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
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
        onSelected: (_) {
          setState(() {
            selectedCategory = label;
          });
        },
      ),
    );
  }
}

