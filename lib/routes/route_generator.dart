//THIS IS AN OPTIONAL FILE NOT COMPULSORY
//SAMPLE CODE

import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
// import '../screens/login_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/login':
        // return MaterialPageRoute(builder: (_) => LoginScreen());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(child: Text('No route defined for ${settings.name}')),
            ));
    }
  }
}
