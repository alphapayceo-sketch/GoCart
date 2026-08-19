import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/constants.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation(
      {super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    SvgPicture svgIcon(String src, {Color? color}) {
      final baseColor = color ?? Theme.of(context).iconTheme.color!;
      final opacity =
          Theme.of(context).brightness == Brightness.dark ? 0.3 : 1.0;
      return SvgPicture.asset(
        src,
        height: 24,
        colorFilter: ColorFilter.mode(
            baseColor.withValues(alpha: opacity), BlendMode.srcIn),
      );
    }

    return Container(
      padding: const EdgeInsets.only(top: defaultPadding / 2),
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : const Color(0xFF101015),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF101015),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.transparent,
        items: [
          BottomNavigationBarItem(
            icon: svgIcon('assets/icons/Shop.svg'),
            activeIcon: svgIcon('assets/icons/Shop.svg', color: primaryColor),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: svgIcon('assets/icons/Category.svg'),
            activeIcon:
                svgIcon('assets/icons/Category.svg', color: primaryColor),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: svgIcon('assets/icons/Bookmark.svg'),
            activeIcon:
                svgIcon('assets/icons/Bookmark.svg', color: primaryColor),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(
            icon: svgIcon('assets/icons/Bag.svg'),
            activeIcon: svgIcon('assets/icons/Bag.svg', color: primaryColor),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: svgIcon('assets/icons/Profile.svg'),
            activeIcon:
                svgIcon('assets/icons/Profile.svg', color: primaryColor),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
