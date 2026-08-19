import 'package:shop/config/app_config.dart';
import 'package:shop/services/api_client.dart';

abstract class WalletRepository {
  Future<Map<String, dynamic>> getWallet();
}

class RemoteWalletRepository implements WalletRepository {
  @override
  Future<Map<String, dynamic>> getWallet() async {
    if (!AppConfig.current.useDemoData) {
      try {
        return ApiClient.getJson('/api/wallet/history');
      } catch (_) {
        return const {
          'balance': 0.0,
          'history': <dynamic>[],
        };
      }
    }

    return const {
      'balance': 0.0,
      'history': <dynamic>[],
    };
  }
}
