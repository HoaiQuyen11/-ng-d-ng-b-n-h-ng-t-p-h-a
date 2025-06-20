import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:minimart/user/page_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'controller/controller_product.dart';



void main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://hathaarwuuqqdnyidryo.supabase.co', //dự án của mình
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhhdGhhYXJ3dXVxcWRueWlkcnlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgwNzUxMTgsImV4cCI6MjA2MzY1MTExOH0.HIs193agd3Ltn6jsN_IbAoQljapF6iFJa_rGoc2jmDk',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo', // tham so khoi tao theo ten cai tieu de app
      debugShowCheckedModeBanner: false,
      initialBinding: BindingAppFruitStore(),

      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      // Thay tên giao diện chạy tại 'home'
      home: PageUser(),
      //const MyHomePage(title: 'Home Page'),
    );
  }
}



