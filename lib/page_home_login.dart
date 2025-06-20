import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:minimart/admin/page_admin.dart';
import 'package:minimart/user/page_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import 'helper/supabase_helper.dart';

AuthResponse? response;

class PageLogin extends StatelessWidget {
  const PageLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(child: Container()),
            SupaEmailAuth(
              onSignInComplete: (AuthResponse response) async {
                final userId = response.user!.id;

                // Kiểm tra nếu user chưa có trong KhachHang thì thêm vào
                final existing = await supabase
                    .from('KhachHang')
                    .select('uid')
                    .eq('uid', userId)
                    .maybeSingle();

                if (existing == null) {
                  await InsertUser(userId); // Chèn mới nếu chưa có
                }

                await HandleLogin(context, userId);
              },
              onSignUpComplete: (AuthResponse response) {
                if (response.user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PageVerify(email: response.user!.email!),
                    ),
                  );
                }
              },
              showConfirmPasswordField: true,
            ),
          ],
        ),
      ),
    );
  }
}

class PageVerify extends StatelessWidget {
  final String email;

  PageVerify({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Xác minh OTP"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OtpTextField(
            numberOfFields: 6,
            borderColor: Color(0xFF512DA8),
            showFieldAsBox: true,
            onCodeChanged: (String code) {},
            onSubmit: (String verificationCode) async {
              final response = await supabase.auth.verifyOTP(
                email: email,
                token: verificationCode,
                type: OtpType.email,
              );

              final user = response.user;
              if (user != null) {
                final existing = await supabase
                    .from('KhachHang')
                    .select('uid')
                    .eq('uid', user.id)
                    .maybeSingle();

                if (existing == null) {
                  await InsertUser(user.id, email: user.email);
                }

                await HandleLogin(context, user.id);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Xác minh OTP thất bại")),
                );
              }
            },

          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Đang gửi mã OTP...")),
              );
              await supabase.auth.signInWithOtp(email: email);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Mã OTP đã được gửi đến $email")),
              );
            },
            child: Text("Gửi lại mã OTP"),
          ),
        ],
      ),
    );
  }
}

Future<void> InsertUser(String userId, {String? email}) async {
  try {
    // Nếu không truyền email thì lấy từ currentUser
    final authEmail = email ?? supabase.auth.currentUser?.email ?? '';

    // Kiểm tra nếu đã có trong KhachHang
    final existing = await supabase
        .from('KhachHang')
        .select('uid')
        .eq('uid', userId)
        .maybeSingle();

    if (existing != null) {
      print("ℹ️ User đã tồn tại trong KhachHang: $userId");
      return;
    }

    await supabase.from('KhachHang').insert({
      'uid': userId,
      'email': authEmail,
      'ten': '',
      'sodienthoai': '',
      'diachi': '',
      'isAdmin': userId == '5ba944f3-cd1b-47fe-9f89-c755da20a9ae',
    });

    print("✅ Đã thêm user vào KhachHang với email: $authEmail");
  } catch (e) {
    print("❌ Lỗi khi chèn user vào KhachHang: $e");
  }
}

Future<void> HandleLogin(BuildContext context, String userId) async {
  try {
    print(" Bắt đầu HandleLogin với userId: $userId");

    final user = await supabase
        .from('KhachHang')
        .select('*')
        .eq('uid', userId)
        .maybeSingle();

    if (user == null) {
      print(" Người dùng không tồn tại trong bảng KhachHang");
      return;
    }

    print(" Đã tìm thấy user: $user");
    final bool isAdmin = user['isAdmin'] == true;
    print(" isAdmin = $isAdmin");

    if (isAdmin) {
      print(" Điều hướng đến trang PageProductAdmin");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => PageProductAdmin()),
              (route) => false,
        );
      });
    } else {
      print("Điều hướng đến trang PageUser");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PageUser()),
        );
      });
    }
  } catch (e) {
    print(" Lỗi khi truy vấn KhachHang hoặc điều hướng: $e");
  }
}


