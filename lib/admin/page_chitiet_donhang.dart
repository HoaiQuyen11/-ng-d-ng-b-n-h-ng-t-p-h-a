import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'page_xem_donhang.dart';

class PageChiTietDonHang extends StatefulWidget {
  const PageChiTietDonHang({super.key});

  @override
  State<PageChiTietDonHang> createState() => _PageChiTietDonHangState();
}

class _PageChiTietDonHangState extends State<PageChiTietDonHang> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> donHangList = [];
  Map<String, List<Map<String, dynamic>>> chiTietMap = {};

  @override
  void initState() {
    super.initState();
    fetchDonHangVaChiTiet();
  }

  Future<void> fetchDonHangVaChiTiet() async {
    final donHangRes = await supabase.from('donhang').select();
    final chiTietRes = await supabase.from('chitietdonhang').select();

    Map<String, List<Map<String, dynamic>>> map = {};
    for (var item in chiTietRes) {
      final orderId = item['order_id'];
      map.putIfAbsent(orderId, () => []).add(item);
    }

    setState(() {
      donHangList = donHangRes;
      chiTietMap = map;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi Tiết Đơn Hàng')),
      body: ListView.builder(
        itemCount: donHangList.length,
        itemBuilder: (context, index) {
          final donHang = donHangList[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => PageXemDonHang(
                  donHang: donHang,
                  chiTiet: chiTietMap[donHang['id']] ?? [],
                ),
              ));
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Khách: ${donHang['ten']} - ${donHang['tongtien']}đ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Ngày đặt: ${donHang['created_at'].toString().substring(0, 19)}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
