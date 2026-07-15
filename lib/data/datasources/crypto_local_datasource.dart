import 'package:hive_flutter/hive_flutter.dart';
import '../models/crypto_coin_model.dart';

abstract class CryptoLocalDataSource {
  Future<List<CryptoCoinModel>> getCachedCoins();
  Future<void> cacheCoins(List<CryptoCoinModel> coins);
  Future<void> cacheSingleCoin(CryptoCoinModel coin);
  Future<CryptoCoinModel?> getCachedCoinById(String id);
}

class CryptoLocalDataSourceImpl implements CryptoLocalDataSource {
  static const String boxName = 'crypto_coins_box';

  Future<Box> _openBox() async {
    return await Hive.openBox(boxName);
  }

  @override
  Future<List<CryptoCoinModel>> getCachedCoins() async {
    final box = await _openBox();
    final List<CryptoCoinModel> coins = [];

    for (var key in box.keys) {
      final raw = box.get(key);
      if (raw != null) {
        final json = Map<String, dynamic>.from(raw as Map);
        coins.add(CryptoCoinModel.fromJson(json));
      }
    }

    return coins;
  }

  @override
  Future<void> cacheCoins(List<CryptoCoinModel> coins) async {
    final box = await _openBox();
    await box.clear();

    for (var coin in coins) {
      await box.put(coin.id, coin.toJson());
    }
  }

  @override
  Future<void> cacheSingleCoin(CryptoCoinModel coin) async {
    final box = await _openBox();
    await box.put(coin.id, coin.toJson());
  }

  @override
  Future<CryptoCoinModel?> getCachedCoinById(String id) async {
    final box = await _openBox();
    final raw = box.get(id);

    if (raw == null) return null;

    final json = Map<String, dynamic>.from(raw as Map);
    return CryptoCoinModel.fromJson(json);
  }
}