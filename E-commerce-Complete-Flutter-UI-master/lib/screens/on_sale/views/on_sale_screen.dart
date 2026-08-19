import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class OnSaleScreen extends StatelessWidget {
  const OnSaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deals = [
      ('Flash sale', 'Up to 50% off', '24 items'),
      ('Weekend discount', 'Save 35%', '18 items'),
      ('Clearance', 'Final markdowns', '12 items'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('On Sale'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(defaultPadding),
        itemCount: deals.length,
        separatorBuilder: (_, __) => const SizedBox(height: defaultPadding),
        itemBuilder: (context, index) {
          final deal = deals[index];
          return Container(
            padding: const EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(defaultBorderRadious),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                  ),
                  child: const Icon(Icons.local_offer, color: primaryColor),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(deal.$1,
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(deal.$2,
                          style: const TextStyle(color: blackColor40)),
                      const SizedBox(height: 4),
                      Text(deal.$3,
                          style: const TextStyle(color: primaryColor)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
