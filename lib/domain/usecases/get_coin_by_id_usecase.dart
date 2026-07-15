import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../entities/crypto_coin.dart';
import '../repositories/crypto_repository.dart';

class GetCoinByIdUseCase {
  final CryptoRepository repository;
  GetCoinByIdUseCase(this.repository);

  Future<Either<Failure, CryptoCoin>> call(String id) async {
    return await repository.getCoinById(id);
  }
}