import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/crypto_coin.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../datasources/crypto_remote_datasource.dart';
import '../datasources/crypto_local_datasource.dart';

class CryptoRepositoryImpl implements CryptoRepository {
  final CryptoRemoteDataSource remoteDataSource;
  final CryptoLocalDataSource localDataSource;

  CryptoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<CryptoCoin>>> getTopCoins() async {
    try {
      final remoteCoins = await remoteDataSource.getTopCoins();
      await localDataSource.cacheCoins(remoteCoins);
      return Right(remoteCoins);
    } catch (e) {
      try {
        final cachedCoins = await localDataSource.getCachedCoins();
        if (cachedCoins.isNotEmpty) {
          return Right(cachedCoins);
        }
        return Left(ServerFailure(message: e.toString()));
      } catch (cacheError) {
        return Left(CacheFailure(message: cacheError.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, CryptoCoin>> getCoinById(String id) async {
    try {
      final remoteCoin = await remoteDataSource.getCoinById(id);
      await localDataSource.cacheSingleCoin(remoteCoin);
      return Right(remoteCoin);
    } catch (e) {
      try {
        final cachedCoin = await localDataSource.getCachedCoinById(id);
        if (cachedCoin != null) {
          return Right(cachedCoin);
        }
        return Left(ServerFailure(message: e.toString()));
      } catch (cacheError) {
        return Left(CacheFailure(message: cacheError.toString()));
      }
    }
  }
}