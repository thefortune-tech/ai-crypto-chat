import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/di/injection_container.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/crypto_coin.dart';
import '../../domain/usecases/get_top_coins_usecase.dart';
import '../../domain/usecases/get_coin_by_id_usecase.dart';

final getTopCoinsUseCaseProvider = Provider<GetTopCoinsUseCase>((ref) {
  return sl<GetTopCoinsUseCase>();
});

final getCoinByIdUseCaseProvider = Provider<GetCoinByIdUseCase>((ref) {
  return sl<GetCoinByIdUseCase>();
});

final topCoinsProvider =
    FutureProvider.autoDispose<List<CryptoCoin>>((ref) async {
  final useCase = ref.watch(getTopCoinsUseCaseProvider);
  final Either<Failure, List<CryptoCoin>> result = await useCase();

  return result.fold(
    (failure) => throw failure.message,
    (coins) => coins,
  );
});

final coinByIdProvider =
    FutureProvider.autoDispose.family<CryptoCoin, String>((ref, id) async {
  final useCase = ref.watch(getCoinByIdUseCaseProvider);
  final Either<Failure, CryptoCoin> result = await useCase(id);

  return result.fold(
    (failure) => throw failure.message,
    (coin) => coin,
  );
});