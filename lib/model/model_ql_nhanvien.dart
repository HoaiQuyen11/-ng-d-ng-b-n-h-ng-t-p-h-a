class Employee {
  final int id; // Giữ nguyên int nếu id của bạn là số nguyên
  final String name;
  final String shift;
  final String? email; // Có thể null
  final String? avatar; // THÊM MỚI: URL ảnh đại diện, có thể null

  Employee({
    required this.id,
    required this.name,
    required this.shift,
    this.email,
    this.avatar, // THÊM MỚI
  });

  // Factory constructor để tạo đối tượng Employee từ dữ liệu JSON (Map<String, dynamic>)
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int,
      name: json['name'] as String,
      shift: json['shift'] as String,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?, // THÊM MỚI: Lấy giá trị avatar
    );
  }

  // Phương thức để chuyển đổi đối tượng Employee thành JSON (Map<String, dynamic>)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shift': shift,
      'email': email,
      'avatar': avatar, // THÊM MỚI
    };
  }
}
