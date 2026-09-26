class TravelPartnerConfig {
  final String name;
  final String url;
  final bool enabled;

  const TravelPartnerConfig({
    required this.name,
    required this.url,
    this.enabled = true,
  });

  static const Map<String, TravelPartnerConfig> partners = {
    'Goibibo': TravelPartnerConfig(
      name: 'Goibibo',
      url: 'https://www.goibibo.com',
    ),
    'redBus': TravelPartnerConfig(
      name: 'redBus',
      url: 'https://www.redbus.in',
    ),
    'Confirmtkt': TravelPartnerConfig(
      name: 'Confirmtkt',
      url: 'https://www.confirmtkt.com',
    ),
  };
}
