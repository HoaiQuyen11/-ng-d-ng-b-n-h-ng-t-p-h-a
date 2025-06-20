import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:minimart/helper/permission_grant.dart';
import 'package:minimart/helper/supabase_helper.dart';
import 'package:minimart/model/model_ql_nhanvien.dart';

class PageAddNhanVien extends StatefulWidget {
  const PageAddNhanVien({super.key});

  @override
  State<PageAddNhanVien> createState() => _PageAddNhanVienState();
}

class _PageAddNhanVienState extends State<PageAddNhanVien> {
  final TextEditingController txtName = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtShift = TextEditingController();
  XFile? _xFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm nhân viên"),
        backgroundColor: const Color(0xFFFFDADA),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _xFile == null
                  ? const Icon(Icons.person, size: 100)
                  : Image.file(File(_xFile!.path), fit: BoxFit.cover),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (await requestPermission(Permission.photos)) {
                  var imageXFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (imageXFile != null) {
                    setState(() {
                      _xFile = imageXFile;
                    });
                  }
                }
              },
              child: const Text("Chọn ảnh"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: txtName,
              decoration: const InputDecoration(labelText: "Tên nhân viên"),
            ),
            TextField(
              controller: txtEmail,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: txtShift,
              decoration: const InputDecoration(labelText: "Ca làm"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String? avatarUrl;
                if (_xFile != null) {
                  avatarUrl = await uploadImage(
                    image: File(_xFile!.path),
                    bucket: 'image',
                    path: 'Employees/${txtName.text}',
                  );
                }

                final employee = Employee(
                  id: 0,
                  name: txtName.text,
                  email: txtEmail.text,
                  shift: txtShift.text,
                  avatar: avatarUrl,
                );

                await supabase.from('employees').insert(employee.toJson());

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Đã thêm nhân viên ${txtName.text}")),
                );

                Navigator.of(context).pop();
              },
              child: const Text("Thêm nhân viên"),
            ),
          ],
        ),
      ),
    );
  }
}
