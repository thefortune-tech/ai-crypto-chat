import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ai_crypto_chat/core/error/failures.dart';
import 'package:ai_crypto_chat/data/datasources/crypto_local_datasource.dart';
import 'package:ai_crypto_chat/data/datasources/crypto_remote_datasource.dart';
import 'package:ai_crypto_chat/data/models/crypto_coin_model.dart';
import 'package:ai_crypto_chat/data/repositories/crypto_repository_impl.dart';
import 'package:ai_crypto_chat/domain/entities/crypto_coin.dart';
import 'package:fpdart/fpdart.dart';

class MockCryptoRemoteDataSource extends Mock implements CryptoRemoteDataSource {}
class MockCryptoLocalDataSource extends Mock implements CryptoLocalDataSource {}

void main() {
  late CryptoRepositoryImpl repository;
  late MockCryptoRemoteDataSource mockRemote;
  late MockCryptoLocalDataSource mockLocal;

  setUp(() {
    mockRemote = MockCryptoRemoteDataSource();
    mockLocal = MockCryptoLocalDataSource();
    repository = CryptoRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });

  const tCoinModel = CryptoCoinModel(
    id: 'bitcoin',
    name: 'Bitcoin',
    symbol: 'btc',
    currentPrice: 65000.0,
    priceChangePercentage24h: 2.5,
    marketCap: 1200000000.0,
    image: 'https://example.com/btc.png',
  );
  final tCoinModelList = [tCoinModel];

  group('getTopCoins', () {
    test('should return Right and cache data when remote call succeeds', () async {
      when(() => mockRemote.getTopCoins()).thenAnswer((_) async => tCoinModelList);
      when(() => mockLocal.cacheCoins(tCoinModelList)).thenAnswer((_) async {});

      final result = await repository.getTopCoins();

      expect(result, Right(tCoinModelList));
      verify(() => mockLocal.cacheCoins(tCoinModelList)).called(1);
    });

    test('should return cached data when remote call fails but cache has data', () async {
      when(() => mockRemote.getTopCoins()).thenThrow(Exception('No internet'));
      when(() => mockLocal.getCachedCoins()).thenAnswer((_) async => tCoinModelList);

      final result = await repository.getTopCoins();

      expect(result, Right(tCoinModelList));
      verify(() => mockLocal.getCachedCoins()).called(1);
    });

    test('should return ServerFailure when remote fails and cache is empty', () async {
      when(() => mockRemote.getTopCoins()).thenThrow(Exception('No internet'));
      when(() => mockLocal.getCachedCoins()).thenAnswer((_) async => []);

      final result = await repository.getTopCoins();

      expect(result, isA<Left<Failure, List<CryptoCoin>>>());
    });

    test('should return CacheFailure when both remote and cache fail', () async {
      when(() => mockRemote.getTopCoins()).thenThrow(Exception('No internet'));
      when(() => mockLocal.getCachedCoins()).thenThrow(Exception('Hive corrupted'));

      final result = await repository.getTopCoins();

      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Expected a Left(CacheFailure)'),
      );
    });
  });
}