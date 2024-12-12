import 'package:orderit/app_viewmodel.dart';
import 'package:orderit/common/services/stock_actual_qty_service.dart';
import 'package:orderit/common/services/doctype_caching_service.dart';
import 'package:orderit/common/services/fetch_cached_doctype_service.dart';
import 'package:orderit/common/viewmodels/profile_viewmodel.dart';
import 'package:orderit/common/views/login_view.dart';
import 'package:orderit/orderit/services/cart_service.dart';
import 'package:orderit/orderit/services/orderit_api_service.dart';
import 'package:orderit/orderit/viewmodels/cart_page_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/draft_detail_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/draft_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/favorites_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/filters/past_orders_filter_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/item_attributes_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/item_category_bottom_nav_bar_viewmodel.dart';
import 'package:orderit/orderit/services/items_api_service.dart';
import 'package:orderit/orderit/viewmodels/items_detail_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/past_orders_detail_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/past_orders_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/search_page_viewmodel.dart';
import 'package:orderit/orderit/services/customer_service.dart';
import 'package:orderit/orderit/services/user_service.dart';
import 'package:orderit/orderit/viewmodels/success_viewmodel.dart';
import 'package:orderit/common/services/common_service.dart';
import 'package:orderit/orderit/widgets/orderit_widgets.dart';
import 'package:orderit/common/services/camera_service.dart';
import 'package:orderit/common/viewmodels/enter_customer_viewmodel.dart';
import 'package:orderit/common/services/login_api_service.dart';
import 'package:orderit/common/viewmodels/login_viewmodel.dart';
import 'package:orderit/common/services/logout_api_service.dart';
import 'package:orderit/common/services/offline_storage_service.dart';
import 'package:orderit/common/services/report_service.dart';
import 'package:orderit/common/services/connectivity_service.dart';
import 'package:orderit/common/services/dialog_service.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/config/theme.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;
// register singleton
Future setUpLocator() async {
  locator.allowReassignment = true;
  var instance = await StorageService.getInstance();
  locator.registerLazySingleton<CommonService>(() => CommonService());
  locator.registerLazySingleton<CustomTheme>(() => CustomTheme());
  locator.registerLazySingleton<DialogService>(() => DialogService());
  locator.registerLazySingleton<LoginService>(() => LoginService());
  locator.registerLazySingleton<LogoutService>(() => LogoutService());
  locator.registerLazySingleton<NavigationService>(() => NavigationService());
  locator.registerLazySingleton<OfflineStorage>(() => OfflineStorage());
  if (instance != null) {
    locator.registerSingleton<StorageService>(instance);
  }
  locator.registerLazySingleton<LoginViewModel>(() => LoginViewModel());
  locator.registerLazySingleton<AppViewModel>(() => AppViewModel());
  locator.registerLazySingleton<ReportService>(() => ReportService());

  //Catalogue
  locator.registerLazySingleton<CartService>(() => CartService());
  locator.registerLazySingleton<ItemsService>(() => ItemsService());
  locator.registerLazySingleton<CartPageViewModel>(() => CartPageViewModel());
  locator.registerLazySingleton<ItemsDetailViewModel>(
      () => ItemsDetailViewModel());
  locator.registerLazySingleton<ItemsViewModel>(() => ItemsViewModel());
  locator
      .registerLazySingleton<SearchPageViewModel>(() => SearchPageViewModel());
  locator.registerLazySingleton<ProfileViewModel>(() => ProfileViewModel());
  locator.registerLazySingleton<UserService>(() => UserService());
  locator.registerLazySingleton<CustomerServices>(() => CustomerServices());
  locator.registerLazySingleton<SuccessViewModel>(() => SuccessViewModel());
  locator.registerLazySingleton<DraftViewModel>(() => DraftViewModel());
  locator.registerLazySingleton<DraftDetailViewModel>(
      () => DraftDetailViewModel());
  locator.registerLazySingleton<PasswordFieldViewModel>(
      () => PasswordFieldViewModel());
  locator.registerLazySingleton<EnterCustomerViewModel>(
      () => EnterCustomerViewModel());
  locator.registerLazySingleton<CameraService>(() => CameraService());
  locator
      .registerLazySingleton<PastOrdersViewModel>(() => PastOrdersViewModel());
  locator.registerLazySingleton<ItemAttributesViewModel>(
      () => ItemAttributesViewModel());
  locator.registerLazySingleton<ItemCategoryBottomNavBarViewModel>(
      () => ItemCategoryBottomNavBarViewModel());
  locator.registerLazySingleton<PastOrdersDetailViewModel>(
      () => PastOrdersDetailViewModel());
  locator.registerLazySingleton<PastOrdersFilterViewModel>(
      () => PastOrdersFilterViewModel());
  locator
      .registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  locator.registerLazySingleton<OrderitWidgets>(() => OrderitWidgets());
  locator.registerLazySingleton<DoctypeCachingService>(
      () => DoctypeCachingService());
  locator.registerLazySingleton<FetchCachedDoctypeService>(
      () => FetchCachedDoctypeService());
  locator.registerLazySingleton<OrderitApiService>(() => OrderitApiService());
  locator.registerLazySingleton<StockActualQtyService>(
      () => StockActualQtyService());
  locator.registerLazySingleton<FavoritesViewModel>(() => FavoritesViewModel());
}
