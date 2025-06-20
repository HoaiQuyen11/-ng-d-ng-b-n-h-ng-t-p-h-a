

import '../helper/supabase_helper.dart';
import 'model_product.dart';

class GioHangItem {
  Product product;
  int soLuong;

  GioHangItem({
    required this.product,
    required this.soLuong
  });


  Map<String, dynamic> toMap() {
    return {
      'Product': this.product.toMap(),
      'soLuong': this.soLuong,
    };
  }

  factory GioHangItem.fromMap(Map<String, dynamic> map) {
    return GioHangItem(
      product: Product.fromMap(map['Product']) as Product,
      soLuong: map['soLuong'] as int,
    );
  }

}

class GioHangSnapshot {
  static Future<List<GioHangItem>> getALL(String uuid) async {
    var response = await supabase.from("GioHang")
        .select("soLuong, Product(*)")
        .eq("idKhachHang", uuid);
    return response.map((e) => GioHangItem.fromMap(e),).toList();
  }

  static Future<void> insert(GioHangItem gh, String uuid, String email) async {
    await supabase.from("GioHang").insert({
      "idProduct": gh.product.id,
      "idKhachHang": uuid,
      "email": email,
      "soLuong": gh.soLuong
    });
  }


  static Future<void> update(GioHangItem gh, String uuid, String email) async {
    await supabase.from("GioHang").upsert({
      "idProduct": gh.product.id,
      "idKhachHang": uuid,
      "email": email,
      "soLuong": gh.soLuong
    });
  }

  static Future<void> delete(Product product, String uuid) async {
    await supabase.from("GioHang").delete()
        .eq("idProduct", product.id)
        .eq("idKhachHang", uuid);
  }
}