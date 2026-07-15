import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/di/injection_container.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';

final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  final repository = sl<AuthRepository>();
  return repository.authStateChanges;
});

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((ref) {
  return sl<SignInWithGoogleUseCase>();
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return sl<SignOutUseCase>();
});

final signInStateProvider =
    AsyncNotifierProvider<SignInNotifier, void>(SignInNotifier.new);

class SignInNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signIn() async {
    state = const AsyncLoading();

    final useCase = ref.read(signInWithGoogleUseCaseProvider);
    final Either<Failure, AppUser> result = await useCase();

    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }
}