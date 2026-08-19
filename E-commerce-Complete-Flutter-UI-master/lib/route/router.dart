import 'package:flutter/material.dart';
import 'package:shop/entry_point.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/screens/product/views/location_permission_store_availability_screen.dart';
import 'package:shop/screens/product/views/product_returns_screen.dart';

import 'screen_export.dart';

// NotificationPermissionScreen()
// PreferredLanguageScreen()
// SelectLanguageScreen()
// SignUpVerificationScreen()
// ProfileSetupScreen()
// VerificationMethodScreen()
// OtpScreen()
// SetNewPasswordScreen()
// DoneResetPasswordScreen()
// TermsOfServicesScreen()
// SetupFingerprintScreen()
// SetupFingerprintScreen()
// SetupFingerprintScreen()
// SetupFingerprintScreen()
// SetupFaceIdScreen()
// OnSaleScreen()
// BannerLStyle2()
// BannerLStyle3()
// BannerLStyle4()
// SearchScreen()
// SearchHistoryScreen()
// NotificationsScreen()
// EnableNotificationScreen()
// NoNotificationScreen()
// NotificationOptionsScreen()
// ProductInfoScreen()
// ShippingMethodsScreen()
// ProductReviewsScreen()
// SizeGuideScreen()
// BrandScreen()
// CartScreen()
// EmptyCartScreen()
// PaymentMethodScreen()
// ThanksForOrderScreen()
// CurrentPasswordScreen()
// EditUserInfoScreen()
// OrdersScreen()
// OrderProcessingScreen()
// OrderDetailsScreen()
// CancleOrderScreen()
// DelivereOrdersdScreen()
// AddressesScreen()
// NoAddressScreen()
// AddNewAddressScreen()
// ServerErrorScreen()
// NoInternetScreen()
// ChatScreen()
// DiscoverWithImageScreen()
// SubDiscoverScreen()
// AddNewCardScreen()
// EmptyPaymentScreen()
// GetHelpScreen()

// ℹ️ All the comments screen are included in the full template
// 🔗 Full template: https://theflutterway.gumroad.com/l/fluttershop

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case onbordingScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const OnBordingScreen(),
      );
    // case preferredLanuageScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const PreferredLanguageScreen(),
    //   );
    case logInScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
    case signUpScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      );
    case emailVerificationScreenRoute:
      final arguments = settings.arguments is Map<String, dynamic>
          ? settings.arguments as Map<String, dynamic>
          : <String, dynamic>{};
      return MaterialPageRoute(
        builder: (context) => EmailVerificationScreen(
          email: arguments['email']?.toString() ?? '',
          nextRoute:
              arguments['nextRoute']?.toString() ?? entryPointScreenRoute,
        ),
      );
    // case profileSetupScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const ProfileSetupScreen(),
    //   );
    case passwordRecoveryScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const PasswordRecoveryScreen(),
      );
    // case verificationMethodScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const VerificationMethodScreen(),
    //   );
    // case otpScreenRoute:
    case otpScreenRoute:
      return MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          email: settings.arguments is String
              ? settings.arguments as String
              : null,
        ),
      );
    case newPasswordScreenRoute:
      return MaterialPageRoute(
        builder: (context) => SetNewPasswordScreen(
          resetToken: settings.arguments is String
              ? settings.arguments as String
              : null,
        ),
      );
    // case newPasswordScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const SetNewPasswordScreen(),
    //   );
    // case doneResetPasswordScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const DoneResetPasswordScreen(),
    //   );
    // case termsOfServicesScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const TermsOfServicesScreen(),
    //   );
    case termsOfServicesScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const TermsOfServicesScreen(),
      );
    // case noInternetScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const NoInternetScreen(),
    //   );
    // case serverErrorScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const ServerErrorScreen(),
    //   );
    // case signUpVerificationScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const SignUpVerificationScreen(),
    //   );
    // case setupFingerprintScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const SetupFingerprintScreen(),
    //   );
    // case setupFaceIdScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const SetupFaceIdScreen(),
    //   );
    case productDetailsScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final dynamic arguments = settings.arguments;

          if (arguments is ProductModel) {
            return ProductDetailsScreen(
              product: arguments,
              isProductAvailable: true,
            );
          }

          final bool isProductAvailable = arguments is bool ? arguments : true;
          return ProductDetailsScreen(isProductAvailable: isProductAvailable);
        },
      );
    case productReviewsScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final product = settings.arguments is ProductModel
              ? settings.arguments as ProductModel
              : null;
          return ProductReviewsScreen(
              productId: product?.id ?? '', product: product);
        },
      );
    case addReviewsScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final arguments =
              settings.arguments is Map ? settings.arguments as Map : const {};
          return WriteReviewScreen(
            productId: arguments['productId']?.toString(),
            product: arguments['product'] is ProductModel
                ? arguments['product'] as ProductModel
                : null,
          );
        },
      );
    case homeScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      );
    case brandScreenRoute:
      final storeName =
          settings.arguments is String ? settings.arguments as String : 'Store';
      return MaterialPageRoute(
        builder: (context) => StoreScreen(storeName: storeName),
        settings: settings,
      );
    // case discoverWithImageScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const DiscoverWithImageScreen(),
    //   );
    // case subDiscoverScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const SubDiscoverScreen(),
    //   );
    case discoverScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const DiscoverScreen(),
      );
    case onSaleScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const OnSaleScreen(),
      );
    case kidsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const KidsScreen(),
      );
    case searchScreenRoute:
      return MaterialPageRoute(
        builder: (context) => SearchScreen(
          categoryId: settings.arguments is String
              ? settings.arguments as String
              : null,
        ),
        settings: settings,
      );
    // case searchHistoryScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const SearchHistoryScreen(),
    //   );
    case bookmarkScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const BookmarkScreen(),
      );
    case wishlistScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const WishlistScreen(),
      );
    case entryPointScreenRoute:
      return MaterialPageRoute(
        builder: (context) => EntryPoint(
          initialIndex:
              settings.arguments is int ? settings.arguments as int : 0,
        ),
        settings: settings,
      );
    case profileScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      );
    // case getHelpScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const GetHelpScreen(),
    //   );
    case getHelpScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const GetHelpScreen(),
      );
    // case chatScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const ChatScreen(),
    //   );
    case userInfoScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const UserInfoScreen(),
      );
    case returnsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const ProductReturnsScreen(),
      );
    case locationPermissionScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const LocationPermissonStoreAvailabilityScreen(),
      );
    // case currentPasswordScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const CurrentPasswordScreen(),
    //   );
    // case editUserInfoScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const EditUserInfoScreen(),
    //   );
    case notificationsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      );
    case noNotificationScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const NoNotificationScreen(),
      );
    case enableNotificationScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EnableNotificationScreen(),
      );
    case notificationOptionsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const NotificationOptionsScreen(),
      );
    // case selectLanguageScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const SelectLanguageScreen(),
    //   );
    case selectLanguageScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const SelectLanguageScreen(),
      );
    // case noAddressScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const NoAddressScreen(),
    //   );
    case addressesScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const AddressesScreen(),
      );
    case shippingMethodsScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final arguments = settings.arguments;

          final products =
              arguments is Map && arguments['products'] is List<ProductModel>
                  ? arguments['products'] as List<ProductModel>
                  : arguments is List<ProductModel>
                      ? arguments
                      : const <ProductModel>[];

          final promoCode =
              arguments is Map ? arguments['promoCode'] as String? : null;

          final promoDiscount = arguments is Map
              ? (arguments['promoDiscount'] as num?)?.toDouble() ?? 0.0
              : 0.0;

          return ShippingMethodsScreen(
            products: products,
            promoCode: promoCode,
            promoDiscount: promoDiscount,
          );
        },
      );
    case addNewAddressesScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const AddAddressScreen(),
      );
    case ordersScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const OrdersScreen(),
      );
    // case orderProcessingScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const OrderProcessingScreen(),
    //   );
    // case orderDetailsScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const OrderDetailsScreen(),
    //   );
    // case cancleOrderScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const CancleOrderScreen(),
    //   );
    // case deliveredOrdersScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const DelivereOrdersdScreen(),
    //   );
    // case cancledOrdersScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const CancledOrdersScreen(),
    //   );
    case preferencesScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const PreferencesScreen(),
      );
    // case emptyPaymentScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const EmptyPaymentScreen(),
    //   );
    case emptyPaymentScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const PaymentMethodsScreen(),
      );
    case emptyWalletScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EmptyWalletScreen(),
      );
    case walletScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const WalletScreen(),
      );
    case cartScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const CartScreen(),
      );
    case paymentMethodScreenRoute:
      return MaterialPageRoute(
        builder: (context) => PaymentMethodsScreen(
          selection: settings.arguments is CheckoutSelection
              ? settings.arguments as CheckoutSelection
              : null,
        ),
        settings: settings,
      );
    // case addNewCardScreenRoute:
    //   return MaterialPageRoute(
    //     builder: (context) => const AddNewCardScreen(),
    //   );
    case thanksForOrderScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const OrderSuccessScreen(),
      );
    case orderSummaryScreenRoute:
      return MaterialPageRoute(
        builder: (context) => OrderSummaryScreen(
          selection: settings.arguments is CheckoutSelection
              ? settings.arguments as CheckoutSelection
              : null,
        ),
        settings: settings,
      );
    case adminHomeScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const AdminHomeScreen(),
      );
    case adminCreateProductScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const AdminCreateProductScreen(),
      );
    case adminEditProductScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final dynamic arguments = settings.arguments;
          if (arguments is ProductModel) {
            return AdminEditProductScreen(product: arguments);
          }
          return const AdminCreateProductScreen();
        },
      );
    case adminProductsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const AdminProductsScreen(),
      );
    case adminMerchantsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const AdminMerchantsScreen(),
      );
    case adminOrdersScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const AdminOrdersScreen(),
      );
    case adminUsersScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const AdminUsersScreen(),
      );
    case adminOperationsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const AdminOperationsScreen(),
      );
    case adminCategoriesScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const AdminCategoriesScreen(),
      );
    case adminCreateCategoryScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const AdminCreateCategoryScreen(),
      );
    case merchantDashboardScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const MerchantDashboardScreen(),
      );
    case merchantOnboardingScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const MerchantOnboardingScreen(),
      );
    case merchantStoreProfileScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const MerchantStoreProfileScreen(),
      );
    case merchantInventoryScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const MerchantInventoryScreen(),
      );
    case merchantProductsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const MerchantProductsScreen(),
      );
    case merchantCategoriesScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const MerchantCategoriesScreen(),
      );
    case merchantOrdersScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const MerchantOrdersScreen(),
      );
    case merchantOrderDetailsScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final arguments = settings.arguments;
          final order = arguments is Map<String, dynamic>
              ? arguments
              : <String, dynamic>{};
          return MerchantOrderDetailsScreen(order: order);
        },
      );
    case merchantFulfillmentScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const MerchantFulfillmentScreen(),
      );
    case merchantSettlementsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const MerchantSettlementsScreen(),
      );
    case merchantStoreScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const MerchantStoreScreen(),
      );
    case merchantProductCreateScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const MerchantCreateProductScreen(),
      );
    case merchantProductEditScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final arguments = settings.arguments;
          final product = arguments is Map<String, dynamic>
              ? arguments
              : <String, dynamic>{};
          return MerchantEditProductScreen(product: product);
        },
      );
    default:
      return MaterialPageRoute(
        // Make a screen for undefine
        builder: (context) => const OnBordingScreen(),
      );
  }
}
