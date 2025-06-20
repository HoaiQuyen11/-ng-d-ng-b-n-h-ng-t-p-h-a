

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../helper/permission_grant.dart';
import '../helper/dialogs.dart';
import '../helper/supabase_helper.dart';
import '../model/model_product.dart';

class PageUpdateProduct extends StatefulWidget {
  PageUpdateProduct({super.key, required this.product});
  Product product;

  @override
  State<PageUpdateProduct> createState() => _PageUpdateProductState();
}

class _PageUpdateProductState extends State<PageUpdateProduct> {
  TextEditingController txtId =TextEditingController();
  TextEditingController txtTen =TextEditingController();
  TextEditingController txtGia =TextEditingController();
  TextEditingController txtMota =TextEditingController();
  XFile? _xFile;
  String? imageUrl;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Chỉnh sửa Sản Phẩm"),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
        body:SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: [
                Container(
                  height: 300,
                  child: _xFile==null ?Image.network(widget.product.anh??"link mac dinh"):
                  Image.file(File(_xFile!.path)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        onPressed: () async{
                          if(await requestPermission(Permission.photos)){
                            var image = await ImagePicker().pickImage(
                                source:   ImageSource.gallery
                            );
                            if(image!=null)
                              setState(() {
                                _xFile=image;
                              });
                          }
                        },
                        child: Text("Chon anh")
                    ),
                    SizedBox(width: 10,)
                  ],
                ),
                TextField(
                  controller: txtId,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false,
                      decimal: false
                  ),
                  decoration: InputDecoration(
                      labelText: "Id"
                  ),
                ),
                TextField(
                  controller: txtTen,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      labelText: "Ten"
                  ),
                ),
                TextField(
                  controller: txtGia,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false,
                      decimal: false
                  ),
                  decoration: InputDecoration(
                      labelText: "Gia"
                  ),
                ),
                TextField(
                  controller: txtMota,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      labelText: "Mo ta"
                  ),
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        Product product = widget.product;
                        showSnackBar(context, message: "Dang cap nhat ${product.ten}...", seconds: 10);
                        if(_xFile!=null){
                          imageUrl = await uploadImage(
                              image: File(_xFile!.path),
                              bucket: "image",
                              path: 'Product/Product_${txtTen.text}'
                          );
                          product.anh=imageUrl;
                        }
                        product.ten=txtTen.text;
                        product.gia=int.parse(txtGia.text);
                        product.moTa=txtMota.text;
                        await ProductSnapshot.update(product);
                        showSnackBar(context, message: "Da cap nhat ${product.ten}");
                      },
                      child: Text("cap nhat"),
                    ),
                    SizedBox(width: 10,)
                  ],
                ),
              ],
            ),
          ),
        )
    );
  }
  @override
  void initState(){
    super.initState();
    txtId.text=widget.product.id.toString();
    txtTen.text=widget.product.ten;
    txtGia.text=widget.product.gia.toString();
    txtMota.text=widget.product.moTa??"";
  }
}
