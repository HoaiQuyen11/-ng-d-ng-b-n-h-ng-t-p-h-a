import 'package:minimart/helper/supabase_helper.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class DonHang {
  final String? id; // id sẽ được Supabase tự tạo
  final String uuid;
  final String ten;
  final String email;
  final String sodienthoai;
  final String diachi;
  final int tongtien;

  DonHang({
    this.id,
    required this.uuid,
    required this.ten,
    required this.email,
    required this.sodienthoai,
    required this.diachi,
    required this.tongtien,
  });

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'ten': ten,
      'email': email,
      'sodienthoai': sodienthoai,
      'diachi': diachi,
      'tongtien': tongtien,
    };
  }

  factory DonHang.fromMap(Map<String, dynamic> map) {
    return DonHang(
      id: map['id'],
      uuid: map['uuid'],
      ten: map['ten'],
      email: map['email'],
      sodienthoai: map['sodienthoai'],
      diachi: map['diachi'],
      tongtien: map['tongtien'],
    );
  }
}

class DonHangSnapshot {
  static Future<List<DonHang>> getAll() async {
    final response = await supabase.from("DonHang").select().order('created_at', ascending: false);
    return response.map<DonHang>((e) => DonHang.fromMap(e)).toList();
  }

  static Future<String?> insert(DonHang donHang) async {
    final response = await Supabase.instance.client
        .from('donhang')
        .insert(donHang.toMap())
        .select('id') // id kiểu uuid
        .single();

    return response['id'] as String?;
  }

  static Future<List<DonHang>> getAllByUser(String uuid) async {
    final response =
    await supabase.from("donhang").select().eq("uuid", uuid);
    return response.map<DonHang>((e) => DonHang.fromMap(e)).toList();
  }
}
