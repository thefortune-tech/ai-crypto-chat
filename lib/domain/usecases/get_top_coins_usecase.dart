import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../entities/crypto_coin.dart';
import '../repositories/crypto_repository.dart';

class GetTopCoinsUseCase {
  final CryptoRepository repository;
  GetTopCoinsUseCase(this.repository);

  Future<Either<Failure, List<CryptoCoin>>> call() async {
    return await repository.getTopCoins();
  }
}