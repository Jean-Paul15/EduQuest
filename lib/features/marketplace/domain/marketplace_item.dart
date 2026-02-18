class MarketplaceItem {
  const MarketplaceItem({
    required this.id,
    required this.title,
    required this.type,
    required this.priceLabel,
    required this.url,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String type;
  final String? priceLabel;
  final String url;
  final String? imageUrl;
}
