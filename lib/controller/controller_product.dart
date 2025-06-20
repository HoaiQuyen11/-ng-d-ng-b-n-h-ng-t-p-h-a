import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/giohang.dart';
import '../model/model_product.dart';

class ControllerProduct extends GetxController {
  var _map = <int, Product>{};
  var GioHang = <GH_Item>[];
  var ghspb = <GioHangItem>[];
  static ControllerProduct get() => Get.find();

  int get slMHGH => GioHang.length;
  Iterable<Product> get products => _map.values;

  String? email;

  @override
  void onInit() {
    super.onInit();
    LoadEmail(); // Tự động gọi khi controller được tạo
  }

  @override
  void onReady() async {
    super.onReady();
    _map = await ProductSnapshot.getMapProduct();
    update(["products"]);
    await loadGioHangFromSupabase(); // <-- sau khi có product
    await xoaGioHangSauThanhToan();
    ProductSnapshot.ListenChangeData(
      _map,
      updateUI: () => this.update(["products"]),
    );
  }

  void themMHGH(Product f) {
    for (var item in GioHang) {
      if (item.product.id == f.id) {
        item.soLuong++;
        update(["gh"]);
        return;
      }
    }
    GioHang.add(GH_Item(product: f, soLuong: 1));
    if (email != null) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        GioHangSnapshot.insert(GioHangItem(product: f, soLuong: 1), userId, email!);
      }
    }
    update(["gh"]);
  }

  Future<void> loadGioHangFromSupabase() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    if (_map.isEmpty) {
      print("_map rỗng => chưa thể ghép sản phẩm với giỏ hàng");
      return;
    }

    final response = await Supabase.instance.client
        .from('GioHang')
        .select()
        .eq('idkhachhang', user.id);

    print("Dữ liệu lấy được từ Supabase: $response");

    if (response != null && response is List) {
      GioHang.clear(); // xoá giỏ cũ

      for (var item in response) {
        final productId = item['idproduct'];
        final soluong = item['soluong'] ?? 1;

        final product = _map[productId];
        if (product != null) {
          GioHang.add(GH_Item(product: product, soLuong: soluong));
        } else {
          print("Không tìm thấy sản phẩm có ID: $productId trong _map");
        }
      }
      update(['gh']);
    }
  }

  Future<void> xoaGioHangSauThanhToan() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('GioHang')
        .delete()
        .eq('idkhachhang', user.id);

    GioHang.clear(); // Xóa local luôn
    update(['gh']);
    print("Đã xoá toàn bộ giỏ hàng của user: ${user.id}");
  }


  Future<void> tangSoLuong(GH_Item item) async {
    item.soLuong++;
    update(['gh']);

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await Supabase.instance.client
          .from('GioHang')
          .update({'soluong': item.soLuong})
          .match({
        'idkhachhang': user.id,
        'idproduct': item.product.id
      });
    }
  }

  Future<void> giamSoLuong(GH_Item item) async {
    if (item.soLuong > 1) {
      item.soLuong--;
      update(['gh']);

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('GioHang')
            .update({'soluong': item.soLuong})
            .match({
          'idkhachhang': user.id,
          'idproduct': item.product.id
        });
      }
    } else {
      // Xoá sản phẩm khỏi giỏ nếu về 0
      GioHang.remove(item);
      update(['gh']);

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('GioHang')
            .delete()
            .match({
          'idkhachhang': user.id,
          'idproduct': item.product.id
        });
      }
    }
  }


  int get tongTien {
    int tong = 0;
    for (var item in GioHang) {
      tong += (item.product.gia ?? 0) * item.soLuong;
    }
    return tong;
  }

  void auth(){
    update(["drawer_header"]);
  }

  getALL_GH(String uuid) async{
    ghspb = await GioHangSnapshot.getALL(uuid);
    update(["gh"]);
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    ProductSnapshot.ListenChangeData(
      _map,
      updateUI: () => this.update(["products"]),
    );
  }

  Future<void> LoadEmail() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      email = null;
    } else {
      final response = await Supabase.instance.client
          .from('Users')
          .select('Email')
          .eq('UID', userId)
          .maybeSingle();

      email = response?['Email']; // Phải dùng đúng key viết hoa
    }
    update(["drawer_header"]);
  }

}

class BindingAppFruitStore extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ControllerProduct());
  }
}

class GH_Item {
  Product product;
  int soLuong;

  GH_Item({
    required this.product,
    required this.soLuong,
  });
}

class SupabaseHelper {
  static final SupabaseClient client = Supabase.instance.client;
  static Session? get response => client.auth.currentSession; // To get the current session
}