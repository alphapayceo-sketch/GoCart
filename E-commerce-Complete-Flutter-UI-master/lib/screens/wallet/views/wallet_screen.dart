import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/wallet_repository.dart';
import 'package:shop/models/product_model.dart';

import 'components/wallet_balance_card.dart';
import 'components/wallet_history_card.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  static final WalletRepository _repository = RemoteWalletRepository();
  late final Future<Map<String, dynamic>> _walletFuture;

  @override
  void initState() {
    super.initState();
    _walletFuture = _repository.getWallet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _walletFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text('Unable to load wallet history right now.'),
                );
              }

              final wallet = snapshot.data ?? const <String, dynamic>{};
              final history = wallet['history'] as List<dynamic>? ?? const [];
              final balance = (wallet['balance'] as num?)?.toDouble() ?? 0.0;
              final historyItems = <({
                bool isReturn,
                String date,
                double amount,
                List<ProductModel> products
              })>[];

              for (var index = 0;
                  index < history.length && index < 2;
                  index++) {
                final item = history[index] as Map<String, dynamic>;
                final products = <ProductModel>[];
                historyItems.add((
                  isReturn: false,
                  date: item['date']?.toString() ?? 'N/A',
                  amount: item['amount'] is num
                      ? (item['amount'] as num).toDouble()
                      : 0.0,
                  products: products,
                ));
              }

              if (historyItems.isEmpty) {
                historyItems.add((
                  isReturn: false,
                  date: 'N/A',
                  amount: 0.0,
                  products: const <ProductModel>[],
                ));
              }

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(vertical: defaultPadding),
                    sliver: SliverToBoxAdapter(
                      child: WalletBalanceCard(
                        balance: balance,
                        onTabChargeBalance: () {},
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(top: defaultPadding / 2),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        "Wallet history",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(top: defaultPadding),
                        child: WalletHistoryCard(
                          isReturn: historyItems[index].isReturn,
                          date: historyItems[index].date,
                          amount: historyItems[index].amount,
                          products: historyItems[index].products,
                        ),
                      ),
                      childCount: historyItems.length,
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
