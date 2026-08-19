import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class KidsScreen extends StatelessWidget {
  const KidsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Back to school', 'From £18', 'assets/icons/Child.svg'),
      ('Summer sets', 'From £24', 'assets/icons/Child.svg'),
      ('Kid essentials', 'From £15', 'assets/icons/Child.svg'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kids'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(defaultPadding),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: defaultPadding),
        itemBuilder: (context, index) {
          final item = items[index];
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
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: blackColor5,
                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                  ),
                  child: const Icon(Icons.child_care, color: primaryColor),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.$1,
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(item.$2,
                          style: const TextStyle(color: blackColor40)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
