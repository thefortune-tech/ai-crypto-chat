import 'package:fpdart/fpdart.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final fb.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRepositoryImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  AppUser _mapFirebaseUser(fb.User user) {
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'Anonymous',
      photoUrl: user.photoURL,
    );
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return _mapFirebaseUser(user);
    });
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return const Left(ServerFailure(message: 'Sign-in cancelled'));
      }

      final googleAuth = await googleUser.authentication;

      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        return const Left(ServerFailure(message: 'Sign-in failed'));
      }

      return Right(_mapFirebaseUser(user));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await googleSignIn.signOut();
      await firebaseAuth.signOut();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}