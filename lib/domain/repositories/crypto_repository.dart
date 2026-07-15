import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../entities/crypto_coin.dart';

abstract class CryptoRepository {
  Future<Either<Failure, List<CryptoCoin>>> getTopCoins();
  Future<Either<Failure, CryptoCoin>> getCoinById(String id);
}