
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helper/supabase_helper.dart';


class Product{
  int id;
  int? gia;
  String ten;
  String? moTa,anh;
  String? phanLoai;

  //Named argument contructor
  Product({
    required this.id,
    this.gia,
    required this.ten,
    this.moTa,
    this.anh,
    this.phanLoai,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'gia': this.gia,
      'ten': this.ten,
      'moTa': this.moTa,
      'anh': this.anh,
      'phanLoai': this.phanLoai,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int,
      gia: map['gia'] as int?,
      ten: map['ten'] as String? ?? "",
      moTa: map['moTa'] as String?,
      anh: map['anh'] as String?,
      phanLoai: map['phanLoai'] as String?,
    );
  }

}//là lớp model class dùng de mota chu k dùng để truy cập dữ liệu
//Snapshot la dung de truy cap du lieu


class ProductSnapshot {
  Product product;
  ProductSnapshot({required this.product});


  static Future<void> update(Product newProduct) async {
    //update không cần trả về bản ghi mới
    final supabase = Supabase.instance.client;
    await supabase
        .from('Product')
        .update(newProduct.toMap())
        .eq('id', newProduct.id);
  }

  static Future<void> delete(int id) async {
    //Xóa bản ghi/thông tin sản phẩm
    final supabase = Supabase.instance.client;
    await supabase
        .from('Product')
        .delete()
        .eq('id', id);
    // Xóa ảnh
    await deleteImage(bucket: "image", path: "Product/Product_$id");
  }

  // Insert không liên quan tới bản ghi --> độc lập --> static
  static Future<void> insert(Product newProduct) async {
    final supabase = Supabase.instance.client;
    await supabase
        .from('Product')
        .insert(newProduct.toMap());
    // upsert = flase: có ảnh rồi thì không ghi đè, chưa có thì update
  }

  static Future<List<Product>> getProducts() async {
    final supabase = Supabase.instance.client;
    List<Product> products = [];
    final data = await supabase.from('Product').select();
    products = data.map(
          (e) => Product.fromMap(e),).toList();
    return products;
  }

  static List<Product> getAll() {
    return data;
  }

  static Future<Map<int, Product>> getMapProduct() async {
    return getMapData(table: "Product",
      fromMap: (map) => Product.fromMap(map),
      getId: (product) => product.id,
    );
  }

  static ListenChangeData(Map<int, Product> maps, {Function()? updateUI}){
    return ListenChangeData2(maps,
        channel: "public:Product",
        schema: "public",
        table: "Product",
        fromMap: (map) => Product.fromMap(map),
        getId: (t) => t.id,
        updateUI: updateUI
    );
  }

  static Stream<List<Product>> getProductStream() {
    var stream = supabase.from("Product")
        .stream(primaryKey: ["id"]);
    return stream.map(
          (mapProducts) =>
          mapProducts.map(
                (e) => Product.fromMap(e),
          ).toList(),
    );
  }
}

final data = <Product>[
  Product(id: 1, ten: "Mì ly Hảo Hảo", gia: 10000, moTa: "Mì ly ăn liền vị tôm chua cay", anh: "https://minhcaumart.vn//media/com_eshop/products/resized/8934563651138-500x500.webp", phanLoai: "Đồ ăn"),
  Product(id: 2, ten: "Mì trộn tương đen Koreno Chajang", gia: 15000, moTa: "Mì trộn tương đen Hàn Quốc", anh: "https://product.hstatic.net/1000323041/product/upload_843590775e484651ae5b567b1c0aed4a_1024x1024.jpg", phanLoai: "Đồ ăn"),
  Product(id: 3, ten: "Mì trộn gà cay Samyang", gia: 25000, moTa: "Mì trộn gà cay vị phô mai", anh: "https://gocbepnhamyt.com/upload/sanpham/mikhogacayviphomaisamyanggoi140g4org-16723171672.jpg", phanLoai: "Đồ ăn"),
  Product(id: 4, ten: "Mỳ ý sốt bò bằm", gia: 30000, moTa: "Mỳ ý sốt cà chua bò bằm", anh: "https://foodparadise.vn/uploads/LONGMONACO/COM_TAY_CAM_GA_XA_XIU__copy.png", phanLoai: "Đồ ăn"),
  Product(id: 5, ten: "Cơm nắm cá hồi nướng", gia: 12000, moTa: "Cơm nắm Nhật nhân cá hồi", anh: "https://salt.tikicdn.com/ts/product/11/c0/3e/3e931c0e75ad8f20fadad9d7a78c347b.png", phanLoai: "Đồ ăn"),
  Product(id: 6, ten: "Hamburger bò", gia: 25000, moTa: "Burger nhân bò phô mai", anh: "https://images.lifesizecustomcutouts.com/image/cache/catalog/incoming/image/data/incoming/image/data/SP02038%20Hamburger%20THUMB-500x500.jpg", phanLoai: "Đồ ăn"),
  Product(id: 7, ten: "Sandwich rau Mayo", gia: 22000, moTa: "Bánh sandwich rau kèm sốy Mayo", anh: "https://mariasmenu.com/wp-content/uploads/Veg-Mayo-Sandwich-500x500.png", phanLoai: "Đồ ăn"),
  Product(id: 8, ten: "Bánh mì chả pate", gia: 18000, moTa: "Bánh mì chả, pate, thịt, rau", anh: "https://alotoday.vn/uploads/images/202311/img_x500_6545bf43929fa1-32166459-54463729.jpg", phanLoai: "Đồ ăn"),
  Product(id: 9, ten: "Kimbap", gia: 18000, moTa: "Kimbap chiên", anh: "https://xienquegiasi.com/ckeditor_assets/pictures/261/content_kimpap-chien-xu-gia-r.jpg", phanLoai: "Đồ ăn"),
  Product(id: 10, ten: "Bánh gạo Tokbokki", gia: 20000, moTa: "Bánh gạo Hàn nhân phô mai", anh: "https://alinafood.vn/wp-content/uploads/2023/04/DMLSBPM0500GFD-Banh-Gao-Tokbokki-Han-Quoc-Nhan-Pho-Mai-500g-4.png", phanLoai: "Đồ ăn"),
  Product(id: 11, ten: "Gà rán", gia: 30000, moTa: "Gà rán nóng giòn", anh: "https://alotoday.vn/uploads/images/202311/img_1920x_6551a621cb6308-52261367-34264417.jpg", phanLoai: "Đồ ăn"),
  Product(id: 12, ten: "Cơm chiên dương châu", gia: 25000, moTa: "Cơm chiên củ quả, trứng", anh: "https://foodparadise.vn/uploads/LONGMONACO/COM_CHIEN_DUONG_CHAU_TRUNG.png", phanLoai: "Đồ ăn"),
  Product(id: 13, ten: "Nui", gia: 35000, moTa: "Nui xào bò", anh: "https://bepxua.vn/wp-content/uploads/2020/12/mom-nui-xao-bo-500x500.jpg", phanLoai: "Đồ ăn"),
  Product(id: 14, ten: "Bánh bao", gia: 15000, moTa: "Bánh bao thịt", anh: "https://takestwoeggs.com/wp-content/uploads/2021/03/Ba%CC%81nh-Bao-Vietnamese-Steamed-Pork-Buns-takestwoeggs-sq-500x500.jpg", phanLoai: "Đồ ăn"),
  Product(id: 15, ten: "Há cảo", gia: 20000, moTa: "Há cảo tôm thịt", anh: "https://dimsumgiabao.com/wp-content/uploads/2024/01/ha-cao-tom-su-2-500x500.jpg", phanLoai: "Đồ ăn"),
  Product(id: 16, ten: "Cháo", gia: 10000, moTa: "Cháo cá nóng ", anh: "https://alinafood.vn/wp-content/uploads/2023/04/KGTKCCA0036OKY-Chao-ca-Okayu-36g-3.png", phanLoai: "Đồ ăn"),
  Product(id: 17, ten: "Súp cua", gia: 25000, moTa: "Súp cua nóng", anh: "https://bepxua.vn/wp-content/uploads/2020/10/sup-cua-500x500.jpg", phanLoai: "Đồ ăn"),
  Product(id: 18, ten: "Salad rau củ", gia: 22000, moTa: "Salad rau củ thập cẩm", anh: "https://dhaba-sardardaa.com/wp-content/uploads/2021/12/salad.jpg", phanLoai: "Đồ ăn"),


  Product(id: 19, ten: "Pepsi", gia: 10000, moTa: "Nước uống có gas", anh: "https://www.bigbasket.com/media/uploads/p/l/40198842_2-pepsi-soft-drink.jpg", phanLoai: "Đồ uống"),
  Product(id: 20, ten: "Sprite", gia: 10000, moTa: "Nước uống có gas", anh: "https://www.getdrinks.co.zw/all_media/2023/09/sprinte-cold-derink-500x500-1.webp", phanLoai: "Đồ uống"),
  Product(id: 21, ten: "CocaCola", gia: 10000, moTa: "Nước uống có gas", anh: "https://csfood.vn/wp-content/uploads/2016/07/N%C6%B0%E1%BB%9Bc-gi%E1%BA%A3i-kh%C3%A1t-Coca-Cola-lon-250ml.jpg", phanLoai: "Đồ uống"),
  Product(id: 22, ten: "Nước cam Twister", gia: 15000, moTa: "Nước trái cây", anh: "https://minhcaumart.vn//media/com_eshop/products/resized/8934588192227-500x500.webp", phanLoai: "Đồ uống"),
  Product(id: 23, ten: "Sữa VinaMilk", gia: 50000, moTa: "Sữa tươi tiệt trùng", anh: "https://satrafoods.com.vn/uploads/Files/vnm-co-duong-500x500.jpg", phanLoai: "Đồ uống"),
  Product(id: 24, ten: "Sữa Ensure", gia: 45000, moTa: "Sữa Ensure Mỹ vị vani", anh: "https://cdn2-retail-images.kiotviet.vn/vuoncuabe/67cd319a19f54109b6b8634e5d02d756.png", phanLoai: "Đồ uống"),
  Product(id: 25, ten: "Sữa gạo Hàn Quốc", gia: 18000, moTa: "Sữa gạo rang", anh: "https://www.boshop.vn/uploads/2018/07/sua-gao-rang-woongjin-1500ml-boshop.jpg", phanLoai: "Đồ uống"),
  Product(id: 26, ten: "Trà xanh nha đam", gia: 12000, moTa: "Trà trái cây", anh: "https://www.bigbasket.com/media/uploads/p/l/40198842_2-pepsi-soft-drink.jpg", phanLoai: "Đồ uống"),
  Product(id: 27, ten: "Trà chanh dây hạt chia FuzeTea", gia: 12000, moTa: "Trà trái cây", anh: "https://satrafoods.com.vn/uploads/Images/san-pham/thuc-pham-cong-nghe/8935049500711-5.jpg", phanLoai: "Đồ uống"),
  Product(id: 28, ten: "Trà Olong Tea Plus", gia: 15000, moTa: "Trà ô lông", anh: "https://minhcaumart.vn//media/com_eshop/products/resized/8934588873140-500x500.webp", phanLoai: "Đồ uống"),
  Product(id: 29, ten: "Nước khoáng Evian", gia: 8000, moTa: "Nước suối", anh: "https://minhcaumart.vn//media/com_eshop/products/resized/8934588873140-500x500.webp", phanLoai: "Đồ uống"),
  Product(id: 30, ten: "Nước Dasani", gia: 7000, moTa: "Nước suối", anh: "https://nuocsuoi.vn/storage/2024/07/nuoc-dasani-500ml-nuocsuoivn-1807243.webp", phanLoai: "Đồ uống"),
  Product(id: 31, ten: "Nước dừa", gia: 22000, moTa: "Nước dừa đóng chai", anh: "https://dafiasianfood.com/wp-content/uploads/2024/05/anh-3-2.jpg", phanLoai: "Đồ uống"),
  Product(id: 32, ten: "Sữa trái cây TH Milk vị dâu", gia: 25000, moTa: "Sữa trái cây", anh: "https://product.hstatic.net/200000078749/product/ong_sua_trai_cay_th_dau_300ml-01_copy_715fd35adba34bd79360cac847a3f0d7_80aa94be67ff4fc68f34478278305221.jpg", phanLoai: "Đồ uống"),
  Product(id: 33, ten: "Sữa trái cây TH Milk vị chuối", gia: 25000, moTa: "Sữa trái cây", anh: "https://minhcaumart.vn//media/com_eshop/products/resized/8936127794404-500x500.webp", phanLoai: "Đồ uống"),
  Product(id: 34, ten: "Trà sữa Macchiato", gia: 22000, moTa: "Trà sữa đóng chai", anh: "https://gocbepnhamyt.com/upload/sanpham/s416716415109-16723192010.jpg", phanLoai: "Đồ uống"),
  Product(id: 35, ten: "Trà sữa trân châu đường đen Đài Loan", gia: 20000, moTa: "Trà sữa đóng chai", anh: "https://minhcaumart.vn//media/com_eshop/products/resized/4710370381499-500x500.webp", phanLoai: "Đồ uống"),
  Product(id: 36, ten: "Cà phê sữa đá Highlands", gia: 20000, moTa: "Cà phê đóng lon", anh: "https://product.hstatic.net/200000352097/product/8936079140014_29fd1031534148389a439d598f7e9b19_1024x1024.png", phanLoai: "Đồ uống"),
  Product(id: 37, ten: "Cà phê Nescafe", gia: 15000, moTa: "Cà phê uống liền", anh: "https://minhcaumart.vn//media/com_eshop/products/resized/8850127003819%201-500x500.jpg", phanLoai: "Đồ uống"),
  Product(id: 38, ten: "Bia Heineken", gia: 22000, moTa: "Bia lon", anh: "https://product.hstatic.net/1000282430/product/bia-heineken-lager-330ml_5ea250ac2a5840f6a541e477b8755e19_grande.jpg", phanLoai: "Đồ uống"),
  Product(id: 39, ten: "Bia Hà Nội", gia: 18000, moTa: "Bia lon", anh: "https://cdn.webshopapp.com/shops/225503/files/475385404/500x500x2/image.jpg", phanLoai: "Đồ uống"),
];


