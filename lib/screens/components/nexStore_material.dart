import 'package:flutter/material.dart';
import '../../routes/navigator_services.dart';
import '../../routes/routes.dart';
import '../../routes/routes_names.dart';
import '../../utils/size_config.dart';
import '../../utils/snack_bar.dart';
import '../../utils/theme.dart';

class thenexstoreMaterial extends StatelessWidget {
  const thenexstoreMaterial({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return MaterialApp(
      scaffoldMessengerKey: SnackBarUtils.rootScaffoldMessengerKey,
      navigatorKey: NavigationService.instance.navigatorKey,  // Add this line
      title: 'thenexstore App',
      debugShowCheckedModeBanner: false,
      theme: theme(),
      initialRoute: RouteNames.splashScreen,
      onGenerateRoute: Routes.generateRoutes,
    );
  }
}