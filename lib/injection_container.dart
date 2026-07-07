import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/network/network_info.dart';
import 'core/services/sync_queue_service.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/guest/data/datasources/guest_local_datasource.dart';
import 'features/guest/data/datasources/guest_remote_datasource.dart';
import 'features/guest/data/repositories/guest_repository_impl.dart';
import 'features/guest/domain/repositories/guest_repository.dart';
import 'features/guest/presentation/bloc/guest_bloc.dart';
import 'features/guest/presentation/bloc/guest_form_bloc.dart';
import 'features/location/data/datasources/location_local_datasource.dart';
import 'features/location/data/datasources/location_remote_datasource.dart';
import 'features/location/data/repositories/location_repository_impl.dart';
import 'features/location/domain/repositories/location_repository.dart';
import 'features/location/presentation/bloc/location_bloc.dart';
import 'features/location/data/services/csv_export_service.dart';
import 'features/notification/data/repositories/notification_repository_impl.dart';
import 'features/notification/domain/repositories/notification_repository.dart';
import 'features/notification/presentation/bloc/notification_bloc.dart';
import 'shared/services/api_client.dart';

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
  final locationBox = await Hive.openBox<String>(AppConstants.boxNameLocations);
  final syncBox = await Hive.openBox<String>(AppConstants.boxNameSyncQueue);
  final authBox = await Hive.openBox<String>(AppConstants.boxNameAuth);

  // ─── Core / Shared ──────────────────────────────────────────────
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // ─── Data Sources ───────────────────────────────────────────────
  getIt.registerLazySingleton<GuestRemoteDataSource>(
    () => GuestRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<GuestLocalDataSource>(
    () => GuestLocalDataSourceImpl(box: guestBox),
  );
  getIt.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<LocationLocalDataSource>(
    () => LocationLocalDataSourceImpl(box: locationBox),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(box: authBox),
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

  getIt.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      remote: getIt<LocationRemoteDataSource>(),
      local: getIt<LocationLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(apiClient: getIt<ApiClient>()),
  );

  // ─── Services ────────────────────────────────────────────────────
  getIt.registerLazySingleton<CsvExportService>(() => const CsvExportService());

  // ─── BLoCs ──────────────────────────────────────────────────────
  getIt.registerFactory(() => GuestBloc(repository: getIt<GuestRepository>()));
  getIt.registerFactory(() => GuestFormBloc());
  getIt.registerFactory(
    () => AuthBloc(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerFactory(
    () => NotificationBloc(
      notificationRepository: getIt<NotificationRepository>(),
    ),
  );
  getIt.registerFactory(
    () => LocationBloc(repository: getIt<LocationRepository>()),
  );
}
