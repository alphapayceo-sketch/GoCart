import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop/screens/notification/view/notificatios_screen.dart';
import 'package:shop/screens/product/views/size_guide_screen.dart';

void main() {
  testWidgets('notifications screen shows real notification settings',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NotificationsScreen()));

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Push notifications'), findsOneWidget);
    expect(find.text('Order updates'), findsOneWidget);
  });

  testWidgets('size guide screen shows actual sizing data', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SizeGuideScreen()));

    expect(find.text('Size guide'), findsOneWidget);
    expect(find.text('US'), findsNWidgets(4));
    expect(find.text('Fit'), findsOneWidget);
  });
}
