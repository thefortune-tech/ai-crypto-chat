import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;
  SignOutUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.signOut();
  }
}