import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../helper/permission_grant.dart';
import '../helper/supabase_helper.dart';
import '../model/model_product.dart';

class PageAddProduct extends StatefulWidget {
  const PageAddProduct({super.key});

  @override
  State<PageAddProduct> createState() => _PageAddProductState();
}


class _PageAddProductState extends State<PageAddProduct> {
  TextEditingController txtID = TextEditingController();
  TextEditingController txtTen = TextEditingController();
  TextEditingController txtGia = TextEditingController();
  TextEditingController txtMoTa = TextEditingController();
  XFile ? _xFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thêm sản phẩm"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                height: 300,
                child: _xFile == null? Icon(Icons.image, size: 50,) :
                Image.file(File(_xFile!.path)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        if(await requestPermission(Permission.photos)){
                          var imageXFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (imageXFile != null) {
                            setState(() {
                              _xFile = imageXFile;
                            });
                          }
                        }
                      },
                      child: Text("Chọn ảnh")
                  ),
                  SizedBox(width: 20,),
                ],
              ),
              TextField(
                controller: txtID,
                keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                decoration: InputDecoration(
                    labelText: "Id"
                ),
              ),
              TextField(
                controller: txtTen,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    labelText: "Tên"
                ),
              ),
              TextField(
                controller: txtGia,
                keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                decoration: InputDecoration(
                    labelText: "Giá"
                ),
              ),
              TextField(
                controller: txtMoTa,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    labelText: "Mô tả"
                ),
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      onPressed: () async{
                        if(_xFile != null){
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Đang thêm ${txtTen.text} ..."),
                              duration: Duration(seconds: 5),
                            ),
                          );
                          var url = await uploadImage(
                              image: File(_xFile!.path),
                              bucket: "image",
                              path: 'Product/Product_${txtTen.text}'
                          );

                          Product product = Product(
                            id: int.parse(txtID.text),
                            ten: txtTen.text,
                            gia: int.parse(txtGia.text),
                            moTa: txtMoTa.text,
                            anh: url,
                          );
                          await ProductSnapshot.insert(product);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Đã thêm ${txtTen.text}"),
                                duration: Duration(seconds: 3),
                              )
                          );
                        }
                      },
                      child: Text("Thêm sản phẩm")
                  ),
                  SizedBox(width: 10,),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}