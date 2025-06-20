import 'package:flutter/material.dart';
import 'package:minimart/model/model_product.dart';

class PageProductFood extends StatelessWidget {
  const PageProductFood({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Product Stream"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<List<Product>>(
        stream: ProductSnapshot.getProductStream(),
        builder: (context, snapshot) {
          if(snapshot.hasError){
            print(snapshot.error.toString());
            return Center(
              child: Text("Lỗi!!!"),
            );
          }
          //Loading
          if(!snapshot.hasData){
            //neu chua co du lieu
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text("Loading..."),
                ],
              ),
            );
          }
          var list = snapshot.data!;
          //var data = snapshot.data!;
          return ListView.separated(
              itemBuilder: (context, index) {
                var product = list[index];
                return Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Image.network(product.anh?? "no image")
                    ),
                    SizedBox(width: 5,),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Id: ${product.id}", style: TextStyle(fontSize: 18)),
                          Text("Tên: ${product.ten}", style: TextStyle(fontSize: 18),),
                          Text("Giá: ${product.gia} dong", style: TextStyle(fontSize: 18)),
                          Text("Mô tả: ${product.moTa}", style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                    SizedBox(height: 5,),
                  ],
                );
              },
              separatorBuilder: (context, index) => Divider(),
              itemCount: list.length
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
