import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/network/network_info.dart';
import 'core/services/sync_queue_service.dart';
import 'features/guest/data/datasources/guest_local_datasource.dart';
import 'features/guest/data/datasources/guest_remote_datasource.dart';
import 'features/guest/data/repositories/guest_repository_impl.dart';
import 'features/guest/domain/repositories/guest_repository.dart';
import 'features/guest/presentation/bloc/guest_bloc.dart';
import 'features/guest/presentation/bloc/guest_form_bloc.dart';

final getIt = GetIt.instance;

/// Initializes all dependency injection registrations.
///
/// Must be called in [main] before [runApp]. Sets up Hive boxes,
/// data sources, repositories, and BLoCs.
Future<void> init() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPrefs);

  // ─── External ───────────────────────────────────────────────────
  await Hive.initFlutter();
  final guestBox = await Hive.openBox<String>(AppConstants.boxNameGuests);
  final syncBox = await Hive.openBox<String>(AppConstants.boxNameSyncQueue);

  // ─── Core ───────────────────────────────────────────────────────
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // ─── Data Sources ───────────────────────────────────────────────
  getIt.registerLazySingleton<GuestRemoteDataSource>(
    () => GuestRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<GuestLocalDataSource>(
    () => GuestLocalDataSourceImpl(box: guestBox),
  );

  // ─── Repositories ───────────────────────────────────────────────
  getIt.registerLazySingleton<SyncQueueService>(
    () => SyncQueueService(
      remoteDataSource: getIt<GuestRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
      syncBox: syncBox,
    ),
  );

  getIt.registerLazySingleton<GuestRepository>(
    () => GuestRepositoryImpl(
      remote: getIt<GuestRemoteDataSource>(),
      local: getIt<GuestLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
      syncQueue: getIt<SyncQueueService>(),
    ),
  );

  // ─── BLoCs ──────────────────────────────────────────────────────
  getIt.registerFactory(
    () => GuestBloc(repository: getIt<GuestRepository>()),
  );
  getIt.registerFactory(() => GuestFormBloc());
}
