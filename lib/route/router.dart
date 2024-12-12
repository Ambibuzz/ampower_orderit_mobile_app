import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/draft.dart';
import 'package:orderit/orderit/models/sales_order.dart';
import 'package:orderit/orderit/views/favorites_view.dart';
import 'package:orderit/orderit/views/item_category_bottom_nav_bar.dart';
import 'package:orderit/orderit/views/cart_page_view.dart';
import 'package:orderit/orderit/views/draft_detail_view.dart';
import 'package:orderit/orderit/views/draft_view.dart';
import 'package:orderit/orderit/views/past_orders_detail_view.dart';
import 'package:orderit/orderit/views/past_orders_view.dart';
import 'package:orderit/common/views/profile_view.dart';
import 'package:orderit/orderit/views/search_page_view.dart';
import 'package:orderit/orderit/views/success_view.dart';
import 'package:orderit/splash/splash_view.dart';
import 'package:orderit/common/views/enter_customer_view.dart';
import 'package:orderit/config/logger.dart';
import 'package:orderit/common/views/login_view.dart';
import 'package:orderit/orderit/views/items_detail_view.dart';
import 'package:orderit/orderit/views/items_view.dart';
import 'package:orderit/route/routing_constants.dart';
import 'package:orderit/route/undefined_view.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:orderit/util/custom_extensions.dart';

final log = getLogger('Router');

Route<dynamic> generateRoute(RouteSettings settings) {
  var routingData = settings.name?.getRoutingData;
  var authCode = routingData?['code'];
  var storageService = locator.get<StorageService>();
  log.i(
      'generateRoute | name: ${settings.name} arguments: ${settings.arguments}');
  switch (settings.name) {
    case loginViewRoute:
      return MaterialPageRoute(
          builder: (context) => LoginView(key: const Key(loginRoute)));
    case favoritesViewRoute:
      var args = settings.arguments as String?;
      return MaterialPageRoute(builder: (context) => const FavoritesView());
    case pastOrdersViewRoute:
      return MaterialPageRoute(builder: (context) => const PastOrdersView());
    case pastOrdersDetailViewRoute:
      var args = settings.arguments as SalesOrder?;
      return MaterialPageRoute(
          builder: (context) => PastOrdersDetailView(salesOrder: args));
    case splashViewRoute:
      return MaterialPageRoute(builder: (context) => const AmpowerAnimation());
    //Catalogue
    case draftRoute:
      return MaterialPageRoute(builder: (context) => const DraftView());
    case draftDetailRoute:
      var draft = settings.arguments as Draft?;
      return MaterialPageRoute(
        builder: (context) => DraftDetailView(
          draft: draft,
          key: const Key(draftDetailRoute),
        ),
      );
    case profileViewRoute:
      return MaterialPageRoute(
          builder: (context) => ProfileView(key: const Key(profileRoute)));
    case cartViewRoute:
      return MaterialPageRoute(
          builder: (context) => CartPageView(key: Key(cartRoute)));
    case searchViewRoute:
      var args = settings.arguments as String?;
      return MaterialPageRoute(
          builder: (context) =>
              SearchPageView(fromView: args, key: const Key(searchRoute)));
    case itemsViewRoute:
      var args = settings.arguments as List<dynamic>;
      Key key;
      if (args[0] != null) {
        key = const Key(itemGroupSearchRoute);
      } else if (args[1] != null && args[2] == true) {
        key = const Key(itemSearchRoute);
      } else {
        key = const Key(particularItemSearchRoute);
      }
      return MaterialPageRoute(
          builder: (context) => ItemsView(
              itemGroup: args[0],
              item: args[1],
              searchText: args[2],
              type: args[3],
              key: const Key(itemsRoute)));
    case itemsDetailViewRoute:
      var item = settings.arguments as String?;
      return MaterialPageRoute(
          builder: (context) =>
              ItemsDetailView(item, key: const Key(itemDetailRoute)));
    case itemCategoryNavBarRoute:
      return MaterialPageRoute(
          builder: (context) => ItemCategoryBottomNavBarView(
              key: const Key(itemCategoryNavBarRoute)));
    case successViewRoute:
      var args = settings.arguments as List<dynamic>;
      return MaterialPageRoute(
          builder: (context) => SuccessView(
              name: args[1],
              doctype: args[0],
              key: const Key(TestCasesConstants.success)));
    case enterCustomerRoute:
      var fromRoute = settings.arguments as String?;
      return MaterialPageRoute(
        builder: (context) => EnterCustomerView(
          key: const Key(Strings.customerSelection),
          fromRoute: fromRoute,
        ),
      );
    default:
      return MaterialPageRoute(
          builder: (context) => UndefinedView(name: settings.name));
  }
}
