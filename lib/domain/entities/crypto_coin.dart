import 'package:equatable/equatable.dart';

class CryptoCoin extends Equatable {
  final String id;
  final String name;
  final String symbol;
  final double currentPrice;
  final double priceChangePercentage24h;
  final double marketCap;
  final String image;

  const CryptoCoin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.currentPrice,
    required this.priceChangePercentage24h,
    required this.marketCap,
    required this.image,
  });

  CryptoCoin copyWith({
    String? id,
    String? name,
    String? symbol,
    double? currentPrice,
    double? priceChangePercentage24h,
    double? marketCap,
    String? image,
  }) {
    return CryptoCoin(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      currentPrice: currentPrice ?? this.currentPrice,
      priceChangePercentage24h:
          priceChangePercentage24h ?? this.priceChangePercentage24h,
      marketCap: marketCap ?? this.marketCap,
      image: image ?? this.image,
    );
  }

  @override
  List<Object?> get props => [
    id, name, symbol, currentPrice,
    priceChangePercentage24h, marketCap, image,
  ];
}