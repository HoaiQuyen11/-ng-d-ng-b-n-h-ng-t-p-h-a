import 'package:minimart/helper/supabase_helper.dart';

import '../helper/supabase_helper.dart';

class ChiTietDonHang {
  final String? id;
  final String orderId;
  final String tenSp;
  final int soluong;
  final int giatien;
  final int thanhtien;

  ChiTietDonHang({
    this.id,
    required this.orderId,
    required this.tenSp,
    required this.soluong,
    required this.giatien,
    required this.thanhtien,
  });

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'ten_sp': tenSp,
      'soluong': soluong,
      'giatien': giatien,
      'thanhtien': thanhtien,
    };
  }

  factory ChiTietDonHang.fromMap(Map<String, dynamic> map) {
    return ChiTietDonHang(
      id: map['id'],
      orderId: map['order_id'],
      tenSp: map['ten_sp'],
      soluong: map['soluong'],
      giatien: map['giatien'],
      thanhtien: map['thanhtien'],
    );
  }
}

class ChiTietDonHangSnapshot {
  static Future<void> insertAll(
      List<ChiTietDonHang> items) async {
    final data = items.map((e) => e.toMap()).toList();
    await supabase.from("chitietdonhang").insert(data);
  }

  static Future<List<ChiTietDonHang>> getByOrder(String orderId) async {
    final response = await supabase
        .from("chitietdonhang")
        .select()
        .eq("order_id", orderId);
    return response
        .map<ChiTietDonHang>((e) => ChiTietDonHang.fromMap(e))
        .toList();
  }
}
