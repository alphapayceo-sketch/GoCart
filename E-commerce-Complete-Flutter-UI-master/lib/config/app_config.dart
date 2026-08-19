class AppConfig {
  const AppConfig({
    required this.appName,
    required this.environment,
    required this.useDemoData,
    required this.baseUrl,
    this.tenantId = '',
  });

  final String appName;
  final String environment;
  final bool useDemoData;
  final String baseUrl;
  final String tenantId;

  static const AppConfig production = AppConfig(
    appName: 'GoCart',
    environment: 'production',
    useDemoData: false,
    baseUrl: 'https://gocart-t1fh.onrender.com',
    tenantId: String.fromEnvironment('GO_CART_TENANT_ID'),
  );

  static const AppConfig development = AppConfig(
    appName: 'GoCart Dev',
    environment: 'development',
    useDemoData: false,
    baseUrl: 'https://gocart-t1fh.onrender.com',
    tenantId: String.fromEnvironment('GO_CART_TENANT_ID'),
  );

  static AppConfig current = production;

  static void setEnvironment(AppConfig config) {
    current = config;
  }

  static String get defaultBaseUrl {
    return 'https://gocart-t1fh.onrender.com';
  }
}
