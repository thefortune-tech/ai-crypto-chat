import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  Future<Either<Failure, AppUser>> signInWithGoogle();
  Future<Either<Failure, Unit>> signOut();
}