import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobilestock/bloc/authentication/authentication_bloc.dart';
import 'package:mobilestock/bloc/webservice/webservice_bloc.dart';
import 'package:mobilestock/core/service_locator.dart';

import 'package:mobilestock/features/cart/cart_list_screen.dart';
import 'package:mobilestock/features/config/config_screen.dart';
import 'package:mobilestock/features/handheld/handheld_list_screen.dart';
import 'package:mobilestock/features/login/login_screen.dart';
import 'package:mobilestock/features/menu/menu_screen.dart';
import 'package:mobilestock/features/requesttransfer/request_cart_list_screen.dart';
import 'package:mobilestock/features/stockdetail/stock_detail_screen.dart';
import 'package:mobilestock/features/transfer/transfer_cart_list_screen.dart';
import 'package:mobilestock/features/barcode/barcode_manage_screen.dart';
import 'package:mobilestock/features/permission/permission_screen.dart';
import 'package:mobilestock/features/pricepermission/price_permission_screen.dart';
import 'package:mobilestock/global.dart';
import 'package:mobilestock/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setUpServiceLocator();
  await initializeConfig();
  runApp(const MyApp());
}

class LastRouteObserver extends NavigatorObserver {
  void _save(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name != null) {
      saveLastRoute(name);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _save(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _save(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _save(previousRoute);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthenticationBloc(),
        ),
        BlocProvider(
          create: (context) => WebserviceBloc(),
        ),
      ],
      child: MaterialApp(
          title: 'Stock Management',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          initialRoute: '/',
          navigatorObservers: [
            LastRouteObserver()
          ],
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/config': (context) => const ConfigScreen(),
            '/menu': (context) => const MenuScreen(),
            '/cartlist': (context) => const CartListScreen(),
            '/stockdetail': (context) => const StockDetailScreen(),
            '/requestcartlist': (context) => const RequestCartListScreen(),
            '/transfercartlist': (context) => const TransferCartListScreen(),
            '/handheldcartlist': (context) => const HandheldListScreen(),
            '/barcodemanage': (context) => const BarcodeManageScreen(),
            '/permission': (context) => const PermissionScreen(),
            '/pricepermission': (context) => const PricePermissionScreen(),
          }),
    );
  }
}
