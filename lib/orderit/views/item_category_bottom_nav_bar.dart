import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/widgets/abstract_factory/iwidgetsfactory.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/viewmodels/item_category_bottom_nav_bar_viewmodel.dart';
import 'package:orderit/orderit/views/draft_view.dart';
import 'package:orderit/orderit/views/favorites_view.dart';
import 'package:orderit/orderit/views/items_view.dart';
import 'package:orderit/orderit/views/past_orders_view.dart';
import 'package:orderit/util/constants/images.dart';
import 'package:orderit/util/enums.dart';
import 'package:orderit/base_view.dart';
import 'package:flutter/material.dart';

//Home class displays ui of different functionalities in form of cards
class ItemCategoryBottomNavBarView extends StatelessWidget {
  ItemCategoryBottomNavBarView({super.key});

  final storageService = locator.get<StorageService>();

  List<Widget> _buildScreens(
      ItemCategoryBottomNavBarViewModel model, BuildContext context) {
    return [
      if (model.itemGroups.isNotEmpty)
        ItemsView(itemGroup: model.itemGroups[0].name),
      const DraftView(),
      const FavoritesView(),
      const PastOrdersView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).primaryColor;
    const inactiveColor = Color(0xFF898A8D);
    var iconSize = 24.0;
    return BaseView<ItemCategoryBottomNavBarViewModel>(
      onModelReady: (model) async {
        await model.getItemGroupsList(context);
        model.loadPages();
      },
      builder: (context, model, child) {
        return Scaffold(
          body: model.state == ViewState.busy
              ? WidgetsFactoryList.circularProgressIndicator()
              : _buildScreens(model, context)[model.currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: model.currentIndex,
            onTap: model.onItemTapped, // Handle tap events
            selectedItemColor: activeColor,
            selectedLabelStyle: TextStyle(
              color: activeColor,
              fontWeight: FontWeight.bold,
            ),
            unselectedItemColor: inactiveColor,
            unselectedLabelStyle: TextStyle(color: inactiveColor),
            showUnselectedLabels: true,
            showSelectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Image.asset(
                  Images.categoryIcon,
                  width: iconSize,
                  height: iconSize,
                ),
                label: 'Categories',
                activeIcon: Image.asset(
                  Images.categoryIcon,
                  color: activeColor,
                  width: iconSize,
                  height: iconSize,
                ),
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  Images.draftsIcon,
                  width: iconSize,
                  height: iconSize,
                ),
                label: 'Wishlist',
                activeIcon: Image.asset(
                  Images.draftsIcon,
                  color: activeColor,
                  width: iconSize,
                  height: iconSize,
                ),
              ),
              BottomNavigationBarItem(
                icon: const Icon(
                  Icons.favorite_border,
                ),
                label: 'Favorites',
                activeIcon: Icon(Icons.favorite, color: activeColor),
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  Images.pastOrdersIcon,
                  width: iconSize,
                  height: iconSize,
                ),
                label: 'Past Orders',
                activeIcon: Image.asset(
                  Images.pastOrdersIcon,
                  color: activeColor,
                  width: iconSize,
                  height: iconSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
