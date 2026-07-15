import '../../domain/entities/crypto_coin.dart';

class CryptoCoinModel extends CryptoCoin {
  const CryptoCoinModel({
    required super.id,
    required super.name,
    required super.symbol,
    required super.currentPrice,
    required super.priceChangePercentage24h,
    required super.marketCap,
    required super.image,
  });

  factory CryptoCoinModel.fromJson(Map<String, dynamic> json) {
    return CryptoCoinModel(
      id: json['id'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      currentPrice: (json['current_price'] as num).toDouble(),
      priceChangePercentage24h:
          (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
      marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'current_price': currentPrice,
      'price_change_percentage_24h': priceChangePercentage24h,
      'market_cap': marketCap,
      'image': image,
    };
  }

  factory CryptoCoinModel.fromEntity(CryptoCoin coin) {
    return CryptoCoinModel(
      id: coin.id,
      name: coin.name,
      symbol: coin.symbol,
      currentPrice: coin.currentPrice,
      priceChangePercentage24h: coin.priceChangePercentage24h,
      marketCap: coin.marketCap,
      image: coin.image,
    );
  }
}