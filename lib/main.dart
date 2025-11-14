import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/screens/components/nexStore_material.dart';
import 'package:thenexstore/utils/app_config.dart';
import 'package:thenexstore/utils/enum.dart';
import 'data/helper/dio_client.dart';
import 'data/services/auth_service.dart';
import 'data/services/notification_service.dart';
import 'data/providers/providers.dart' as providers;
import 'firebase_option.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  ApiConfig.setEnvironment(Environment.dev);
  final prefs = await SharedPreferences.getInstance();
  final authManager = AuthTokenService(prefs);
  await DioClient.instance.init(authManager);

  final notificationService = NotificationService(authManager: authManager);
  await notificationService.subscribeToTopic('offers');

  runApp(
      MultiProvider(
          providers: [
            Provider<AuthTokenService>(create: (_) => authManager), // Use the same instance
            Provider<NotificationService>(create: (_) => notificationService), // Provide NotificationService
            ChangeNotifierProvider(
              create: (context) => providers.AuthenticationProvider(
                authManager: context.read<AuthTokenService>(),
              ),
            ),
            ChangeNotifierProvider(create: (_) => providers.CartProvider()),
            ChangeNotifierProvider(create: (_) => providers.ProductsDataProvider()),
            ChangeNotifierProvider(create: (_) => providers.OrderProvider()),
            ChangeNotifierProvider(create: (_) => providers.ProfileProvider()),
            ChangeNotifierProvider(create: (_) => providers.AddressProvider()..getCurrentLocation()),
            ChangeNotifierProvider(create: (_) => providers.UserProvider()),
            ChangeNotifierProvider(create: (_) => providers.SearchDataProvider()),
            ChangeNotifierProvider(create: (_) => providers.CheckoutProvider()),
            ChangeNotifierProvider(create: (_) => providers.CategoryProvider()),
            ChangeNotifierProvider(create: (_) => providers.HomeDataProvider()),
            ChangeNotifierProvider(create: (_) => providers.WishListProvider()),
            ChangeNotifierProvider(create: (_) => providers.PaymentProvider()),
            ChangeNotifierProvider(create: (_) => providers.NotificationProvider()),
          ],
          child: thenexstoreApp(notificationService: notificationService)));
 }


  class thenexstoreApp extends StatelessWidget {
    final NotificationService notificationService;
    const thenexstoreApp({super.key, required this.notificationService});
    @override
    Widget build(BuildContext context) {
      return notificationService.buildApp(const thenexstoreMaterial());
    }
  }