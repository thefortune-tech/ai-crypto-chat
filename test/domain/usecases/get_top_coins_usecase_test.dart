import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ai_crypto_chat/core/error/failures.dart';
import 'package:ai_crypto_chat/domain/entities/crypto_coin.dart';
import 'package:ai_crypto_chat/domain/repositories/crypto_repository.dart';
import 'package:ai_crypto_chat/domain/usecases/get_top_coins_usecase.dart';

class MockCryptoRepository extends Mock implements CryptoRepository {}

void main() {
  late GetTopCoinsUseCase useCase;
  late MockCryptoRepository mockRepository;

  setUp(() {
    mockRepository = MockCryptoRepository();
    useCase = GetTopCoinsUseCase(mockRepository);
  });

  const tCoin = CryptoCoin(
    id: 'bitcoin',
    name: 'Bitcoin',
    symbol: 'btc',
    currentPrice: 65000.0,
    priceChangePercentage24h: 2.5,
    marketCap: 1200000000.0,
    image: 'https://example.com/btc.png',
  );

  final tCoinList = [tCoin];

  test('should return list of coins from repository on success', () async {
    when(() => mockRepository.getTopCoins())
        .thenAnswer((_) async => Right(tCoinList));

    final result = await useCase();

    expect(result, Right(tCoinList));
    verify(() => mockRepository.getTopCoins()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return a Failure when repository call fails', () async {
    const tFailure = ServerFailure(message: 'Server error');
    when(() => mockRepository.getTopCoins())
        .thenAnswer((_) async => const Left(tFailure));

    final result = await useCase();

    expect(result, const Left(tFailure));
    verify(() => mockRepository.getTopCoins()).called(1);
  });
}