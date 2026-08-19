import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/components/list_tile/divider_list_tile.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/services/auth_service.dart';
import 'package:shop/services/biometric_auth_service.dart';

import 'components/profile_card.dart';
import 'components/profile_menu_item_list_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _biometricsSupported = false;
  bool _biometricsEnabled = false;
  bool _isUpdatingBiometric = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final isSupported = await BiometricAuthService.isSupportedOnDevice();
    final isEnabled = await BiometricAuthService.isEnabled();

    if (!mounted) {
      return;
    }

    setState(() {
      _biometricsSupported = isSupported;
      _biometricsEnabled = isEnabled;
    });
  }

  Future<void> _toggleBiometricLogin(bool value) async {
    if (!_biometricsSupported) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Biometric authentication is not available on this device.'),
        ),
      );
      return;
    }

    setState(() => _isUpdatingBiometric = true);

    try {
      final hasSavedCredentials =
          await BiometricAuthService.hasSavedCredentials();

      if (value && !hasSavedCredentials) {
        throw Exception(
          'Complete a normal login once before turning on biometric sign-in.',
        );
      }

      if (value) {
        final authenticated = await BiometricAuthService.authenticate();
        if (!authenticated) {
          throw Exception('Biometric authentication failed.');
        }
      }

      await BiometricAuthService.setEnabled(value);

      if (!mounted) {
        return;
      }

      await _loadBiometricState();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );

      setState(() => _biometricsEnabled = false);
    } finally {
      if (mounted) {
        setState(() => _isUpdatingBiometric = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileName = AuthService.currentUserName;
    final profileEmail = AuthService.currentUserEmail;
    final profileImage = AuthService.currentUserImage;

    return Scaffold(
      body: ListView(
        children: [
          ProfileCard(
            name: profileName,
            email: profileEmail.isEmpty ? 'user@example.com' : profileEmail,
            imageSrc: profileImage.isEmpty
                ? 'https://i.pravatar.cc/100?u=default'
                : profileImage,
            // proLableText: "Sliver",
            // isPro: true, if the user is pro
            press: () {
              Navigator.pushNamed(context, userInfoScreenRoute);
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Text(
              "Account",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          ProfileMenuListTile(
            text: "Orders",
            svgSrc: "assets/icons/Order.svg",
            press: () {
              Navigator.pushNamed(context, ordersScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Returns",
            svgSrc: "assets/icons/Return.svg",
            press: () {
              Navigator.pushNamed(context, returnsScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Wishlist",
            svgSrc: "assets/icons/Wishlist.svg",
            press: () {
              Navigator.pushNamed(context, wishlistScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Addresses",
            svgSrc: "assets/icons/Address.svg",
            press: () {
              Navigator.pushNamed(context, addressesScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Payment",
            svgSrc: "assets/icons/card.svg",
            press: () {
              Navigator.pushNamed(context, emptyPaymentScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Wallet",
            svgSrc: "assets/icons/Wallet.svg",
            press: () {
              Navigator.pushNamed(context, walletScreenRoute);
            },
          ),
          const SizedBox(height: defaultPadding),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding / 2),
            child: Text(
              "Personalization",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          DividerListTileWithTrilingText(
            svgSrc: "assets/icons/Notification.svg",
            title: "Notification",
            trilingText: "Off",
            press: () {
              Navigator.pushNamed(context, enableNotificationScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Preferences",
            svgSrc: "assets/icons/Preferences.svg",
            press: () {
              Navigator.pushNamed(context, preferencesScreenRoute);
            },
          ),
          const SizedBox(height: defaultPadding),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding / 2),
            child: Text(
              "Settings",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ProfileMenuListTile(
            text: "Language",
            svgSrc: "assets/icons/Language.svg",
            press: () {
              Navigator.pushNamed(context, selectLanguageScreenRoute);
            },
          ),
          SwitchListTile(
            value: _biometricsEnabled,
            onChanged: _isUpdatingBiometric ? null : _toggleBiometricLogin,
            title: const Text('Biometric Login'),
            subtitle: Text(
              _biometricsSupported
                  ? 'Use fingerprint or Face ID to secure this app'
                  : 'Biometrics are not available on this device',
            ),
            secondary: SvgPicture.asset(
              'assets/icons/Lock.svg',
              height: 24,
              width: 24,
            ),
          ),
          ProfileMenuListTile(
            text: "Location",
            svgSrc: "assets/icons/Location.svg",
            press: () {
              Navigator.pushNamed(context, locationPermissionScreenRoute);
            },
          ),
          if (AuthService.isMerchant) ...[
            const SizedBox(height: defaultPadding),
            ProfileMenuListTile(
              text: AuthService.isAdmin ? "Admin Panel" : "Merchant Center",
              svgSrc: "assets/icons/Settings.svg",
              press: () {
                Navigator.pushNamed(
                    context,
                    AuthService.isAdmin
                        ? adminHomeScreenRoute
                        : merchantDashboardScreenRoute);
              },
            ),
            const SizedBox(height: defaultPadding),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding / 2),
            child: Text(
              "Help & Support",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ProfileMenuListTile(
            text: "Get Help",
            svgSrc: "assets/icons/Help.svg",
            press: () {
              Navigator.pushNamed(context, getHelpScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "FAQ",
            svgSrc: "assets/icons/FAQ.svg",
            press: () {},
            isShowDivider: false,
          ),
          const SizedBox(height: defaultPadding),

          // Log Out
          ListTile(
            onTap: () async {
              final navigator = Navigator.of(context);
              await AuthService.logout();
              if (!mounted) return;
              navigator.pushNamedAndRemoveUntil(
                logInScreenRoute,
                (route) => false,
              );
            },
            minLeadingWidth: 24,
            leading: SvgPicture.asset(
              "assets/icons/Logout.svg",
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                errorColor,
                BlendMode.srcIn,
              ),
            ),
            title: const Text(
              "Log Out",
              style: TextStyle(color: errorColor, fontSize: 14, height: 1),
            ),
          )
        ],
      ),
    );
  }
}
