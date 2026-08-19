# StyleHub Frontend

A Flutter-based e-commerce frontend UI for a modern shopping application. This project focuses on the mobile app interface for onboarding, authentication, product browsing, cart, checkout, wallet, orders, and user profile flows.

## Overview

This repository contains the frontend experience for a shop app built with Flutter. It includes a set of polished screens and reusable UI patterns for both Android and iOS, designed to be easy to customize and connect to a real backend later.

The app is structured around a route-based navigation system and theme-driven UI, with screens organized by feature area such as home, product, checkout, and profile.

## Features

- Onboarding flow
- Login and authentication screens
- Password recovery and OTP verification
- Product listing and detail pages
- Search and filters
- Cart and checkout process
- Order summary and success screens
- Profile and account management
- Wallet, payment, and address flows
- Light and dark theme support
- Responsive UI for mobile app screens

## Tech Stack

- Flutter
- Dart
- Material Design widgets
- Shared Preferences
- Local authentication
- Image picker
- HTTP client
- Secure storage
- Flutter SVG and cached images

## Project Structure

```text
.
├── android/
├── ios/
├── assets/
│   ├── fonts/
│   ├── icons/
│   ├── images/
│   ├── Illustration/
│   ├── logo/
│   └── screens/
├── lib/
│   ├── components/
│   ├── config/
│   ├── constants.dart
│   ├── data/
│   ├── main.dart
│   ├── models/
│   ├── route/
│   ├── screens/
│   ├── services/
│   └── theme/
├── test/
├── web/
├── analysis_options.yaml
├── pubspec.yaml
├── README.md
└── .gitignore
```

## Screen Inventory

This frontend includes the following screens, based on the app's route exports and screen structure:

### Authentication & Onboarding

- Onboarding screen
- Login screen
- Sign up screen
- Password recovery screen
- OTP verification screen
- Terms of services screen

### Home, Catalog & Discovery

- Home screen
- Discover screen
- Kids screen
- On sale screen
- Bookmark screen
- Search screen
- Product details screen
- Product reviews screen
- Size guide screen
- Product returns screen
- Product buy now screen
- Added to cart message screen
- Store availability / location permission screen

### Cart, Checkout & Orders

- Cart screen
- Add address screen
- Addresses screen
- Shipping methods screen
- Order summary screen
- Order success screen
- Orders screen
- Payment methods screen
- Wishlist screen
- Write review screen

### Account, Profile & Settings

- Profile screen
- User info screen
- Preferences screen
- Language selection screen
- Get help screen
- Notification options screen
- Notifications screen
- Enable notification screen
- No notification screen

### Wallet, Payments & Address Management

- Wallet screen
- Empty wallet screen
- Empty payment screen

### Admin Screens

- Admin home screen
- Admin products screen
- Admin create product screen
- Admin edit product screen
- Admin categories screen
- Admin create category screen

### Full screen list summary

The project currently includes screens for:

- onboarding
- login/signup/auth flows
- password reset and OTP verification
- home and category browsing
- search and product discovery
- product detail and review flows
- cart and checkout actions
- orders and payment flows
- profile and account management
- notifications and language settings
- wallet and help sections
- admin inventory and category management

## Getting Started

### Prerequisites

Make sure you have the following installed:

- Flutter SDK (>= 3.2.0)
- Android Studio or VS Code with Flutter extensions
- Xcode for iOS development on macOS
- An emulator or physical device

### Installation

1. Clone the repository

```bash
git clone <repository-url>
cd E-commerce-Complete-Flutter-UI-master
```

2. Install dependencies

```bash
flutter pub get
```

3. Run the app

```bash
flutter run
```

### Common build commands

```bash
flutter analyze
flutter test
flutter build apk
flutter build ios
```

## App Configuration

The app entry point is in `lib/main.dart`. It initializes app services and decides the initial route based on whether onboarding has already been seen.

Core application configuration includes:

- Route generation via the router
- Theme setup via `lib/theme/app_theme.dart`
- Notification socket initialization at startup
- Shared preferences for onboarding state

## Theme and Styling

The app uses a custom theme system defined under:

- `lib/theme/`
- `lib/constants.dart`

This keeps the design consistent across screens and supports dark/light theme switching.

## Backend Note

This repository is a frontend UI project. It is designed to be connected to a backend such as:

- Firebase
- REST API
- custom backend service
- Node.js or Laravel API

The UI and route structure are already in place, so you can integrate real business logic next.

## Useful Files

- `lib/main.dart` — app entry point
- `lib/route/router.dart` — route handling
- `lib/screens/` — all feature screens
- `lib/services/` — API/service integration logic
- `lib/theme/` — theme and styling
- `pubspec.yaml` — dependency and project metadata

## Customization

To adapt this frontend for your brand:

- change colors and typography in the theme files
- replace placeholder images and branding assets in `assets/`
- update app name and package configuration
- wire your own product data and APIs in the services layer
- add or remove screens based on your business flow

## License

This project is provided as a frontend UI template for learning and development. Please check the project license terms and usage rights before commercial deployment.

## Contributing

Contributions are welcome. If you want to improve the UI, add screens, or improve structure:

1. fork the project
2. create a feature branch
3. make your changes
4. open a pull request

## Support

For setup issues or development questions, open an issue in the repository and include:

- Flutter version
- device/platform
- current error output
- steps to reproduce
