import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/crypto_coin_model.dart';

abstract class CryptoRemoteDataSource {
  Future<List<CryptoCoinModel>> getTopCoins();
  Future<CryptoCoinModel> getCoinById(String id);
}

class CryptoRemoteDataSourceImpl implements CryptoRemoteDataSource {
  final Dio dio;

  CryptoRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CryptoCoinModel>> getTopCoins() async {
    try {
      final response = await dio.get(
        '${AppConstants.coinGeckoBaseUrl}/coins/markets',
        queryParameters: {
          'vs_currency': 'usd',
          'order': 'market_cap_desc',
          'per_page': 50,
          'page': 1,
          'sparkline': false,
        },
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => CryptoCoinModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch top coins: ${e.message}');
    }
  }

  @override
  Future<CryptoCoinModel> getCoinById(String id) async {
    try {
      final response = await dio.get(
        '${AppConstants.coinGeckoBaseUrl}/coins/markets',
        queryParameters: {
          'vs_currency': 'usd',
          'ids': id,
        },
      );

      final List<dynamic> data = response.data as List<dynamic>;

      if (data.isEmpty) {
        throw Exception('Coin with id "$id" not found');
      }

      return CryptoCoinModel.fromJson(data.first as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to fetch coin $id: ${e.message}');
    }
  }
}