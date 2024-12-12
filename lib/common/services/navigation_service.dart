import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'navigation_key');

  Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushReplacementNamed(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushNamedAndRemoveUntil(
      String routeName, bool Function(Route<dynamic>) predicate,
      {dynamic arguments}) {
    return navigatorKey.currentState!
        .pushNamedAndRemoveUntil(routeName, predicate, arguments: arguments);
  }

  void pop({dynamic result}) {
    return navigatorKey.currentState!.pop<dynamic>([result]);
  }

  Future<dynamic> popAndPushNamed(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!
        .popAndPushNamed(routeName, arguments: arguments);
  }
}
