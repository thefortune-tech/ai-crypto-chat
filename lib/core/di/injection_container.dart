import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../domain/repositories/crypto_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_top_coins_usecase.dart';
import '../../domain/usecases/get_coin_by_id_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/get_chat_history_usecase.dart';
import '../../domain/usecases/save_message_usecase.dart';
import '../../domain/usecases/clear_history_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';

import '../../data/repositories/crypto_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/crypto_remote_datasource.dart';
import '../../data/datasources/crypto_local_datasource.dart';
import '../../data/datasources/ai_remote_datasource.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/datasources/chat_local_datasource.dart';

import '../../presentation/bloc/chat_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── External packages ──────────────────────────
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  sl.registerLazySingleton<Uuid>(() => const Uuid());

  // ── Data sources ────────────────────────────────
  sl.registerLazySingleton<CryptoRemoteDataSource>(
    () => CryptoRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<CryptoLocalDataSource>(
    () => CryptoLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<AiRemoteDataSource>(
    () => AiRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()),
  );
  sl.registerLazySingleton<ChatLocalDataSource>(
    () => ChatLocalDataSourceImpl(),
  );

  // ── Repositories ────────────────────────────────
  sl.registerLazySingleton<CryptoRepository>(
    () => CryptoRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      aiRemoteDataSource: sl(),
      chatRemoteDataSource: sl(),
      chatLocalDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
    ),
  );

  // ── Use cases ───────────────────────────────────
  sl.registerLazySingleton(() => GetTopCoinsUseCase(sl()));
  sl.registerLazySingleton(() => GetCoinByIdUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetChatHistoryUseCase(sl()));
  sl.registerLazySingleton(() => SaveMessageUseCase(sl()));
  sl.registerLazySingleton(() => ClearHistoryUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));

  // ── Blocs ───────────────────────────────────────
  sl.registerFactory<ChatBloc>(
    () => ChatBloc(
      sendMessageUseCase: sl(),
      getChatHistoryUseCase: sl(),
      saveMessageUseCase: sl(),
      clearHistoryUseCase: sl(),
      uuid: sl(),
    ),
  );
}