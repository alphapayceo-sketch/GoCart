import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class SizeGuideScreen extends StatefulWidget {
  const SizeGuideScreen({super.key});

  @override
  State<SizeGuideScreen> createState() => _SizeGuideScreenState();
}

class _SizeGuideScreenState extends State<SizeGuideScreen> {
  bool _isShowCentimetersSize = false;

  void updateSizes() {
    setState(() {
      _isShowCentimetersSize = !_isShowCentimetersSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sizeTable = _isShowCentimetersSize
        ? const [
            _SizeRow('EU', '36', '62', '94', '74'),
            _SizeRow('EU', '38', '64', '98', '78'),
            _SizeRow('EU', '40', '66', '101', '82'),
            _SizeRow('EU', '42', '69', '106', '86'),
          ]
        : const [
            _SizeRow('US', '6', 'S', '23.5', '34'),
            _SizeRow('US', '8', 'M', '24.5', '35'),
            _SizeRow('US', '10', 'L', '25.5', '36'),
            _SizeRow('US', '12', 'XL', '27', '38'),
          ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Size guide'),
        actions: [
          TextButton(
            onPressed: updateSizes,
            child: Text(
              _isShowCentimetersSize ? 'Inches' : 'CM',
              style: const TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find the right fit for your measurements.',
              style: TextStyle(color: blackColor60),
            ),
            const SizedBox(height: defaultPadding),
            Container(
              decoration: BoxDecoration(
                color: blackColor5,
                borderRadius: BorderRadius.circular(defaultBorderRadious),
              ),
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding / 2),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1.2),
                  },
                  children: [
                    const TableRow(
                      children: [
                        Text('Region',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('Size',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('Fit',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('Waist',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    ...sizeTable.map(
                      (row) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(row.region),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(row.size),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(row.fit),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(row.waist),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: defaultPadding),
            const Text(
              'Tip: If you are between sizes, size up for a more relaxed fit.',
              style: TextStyle(color: blackColor40),
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeRow {
  const _SizeRow(this.region, this.size, this.fit, this.waist,
      [this.waist2 = '']);

  final String region;
  final String size;
  final String fit;
  final String waist;
  final String waist2;
}
