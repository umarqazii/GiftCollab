import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gift_collab/data/services/auth_service.dart';
import 'package:gift_collab/routes/app_routes.dart';
import 'data/services/storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Get.putAsync(() => AuthService().init());
  
  await Get.putAsync(() => StorageService().init());

  Stripe.publishableKey = 'pk_test_51SuB79P3xUxwl1zGRDmqR1LFb0zWXzWNvQI0uLqLnLK1wTr5YUNRy6RK7HE3VQkXxrsS02LCMOIh3lN5U1GRC02Z00EVFfpvqF';
  await Stripe.instance.applySettings();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Gift Collab',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      getPages: Routes().routeMap,
    );
  }
}