import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;
  SignInWithGoogleUseCase(this.repository);

  Future<Either<Failure, AppUser>> call() async {
    return await repository.signInWithGoogle();
  }
}