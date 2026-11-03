import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../network/network_info.dart';
import '../services/firebase_messaging_service.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';

import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_stats.dart';
import '../../features/home/domain/usecases/get_nearest_harvests.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

import '../../features/hive/data/datasources/hive_remote_datasource.dart';
import '../../features/hive/data/repositories/hive_repository_impl.dart';
import '../../features/hive/domain/repositories/hive_repository.dart';
import '../../features/hive/domain/usecases/get_hive_detail.dart' as hive;
import '../../features/hive/domain/usecases/get_hive_harvesters.dart';
import '../../features/hive/domain/usecases/get_hive_schedules.dart';
import '../../features/hive/domain/usecases/add_hive.dart';
import '../../features/hive/domain/usecases/upload_image.dart';
import '../../features/hive/domain/usecases/update_hive.dart';
import '../../features/hive/domain/usecases/delete_hive.dart';
import '../../features/hive/domain/usecases/set_harvest_schedule.dart';
import '../../features/hive/domain/usecases/record_harvest.dart';
import '../../features/hive/presentation/bloc/hive_detail_bloc.dart';
import '../../features/hive/presentation/bloc/add_hive_bloc.dart';

import '../../features/schedule/data/datasources/schedule_remote_datasource.dart';
import '../../features/schedule/data/repositories/schedule_repository_impl.dart';
import '../../features/schedule/domain/repositories/schedule_repository.dart';
import '../../features/schedule/domain/usecases/get_harvest_schedules.dart';
import '../../features/schedule/presentation/bloc/schedule_bloc.dart';

import '../../features/map/data/datasources/map_remote_datasource.dart';
import '../../features/map/data/repositories/map_repository_impl.dart';
import '../../features/map/domain/repositories/map_repository.dart';
import '../../features/map/domain/usecases/get_hive_detail.dart';
import '../../features/map/domain/usecases/get_hives.dart';
import '../../features/map/presentation/bloc/map_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── Auth ──────────────────────────────────────────────
  sl.registerLazySingleton(
    () => AuthBloc(
      login: sl(),
      logout: sl(),
      repository: sl(),
      messagingService: sl(),
    ),
  );
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
      apiClient: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  // ── Home ──────────────────────────────────────────────
  sl.registerFactory(
    () => HomeBloc(getHomeStats: sl(), getNearestHarvests: sl()),
  );
  sl.registerLazySingleton(() => GetHomeStats(sl()));
  sl.registerLazySingleton(() => GetNearestHarvests(sl()));
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(sl()),
  );

  // ── Hive Detail ───────────────────────────────────────
  sl.registerFactory(
    () => HiveDetailBloc(
      getHiveDetail: sl(),
      getHiveHarvesters: sl(),
      getHiveSchedules: sl(),
      deleteHive: sl(),
      setHarvestSchedule: sl(),
      recordHarvest: sl(),
      uploadImage: sl(),
    ),
  );
  sl.registerFactory(
    () => AddHiveBloc(uploadImage: sl(), addHive: sl(), setHarvestSchedule: sl()),
  );
  sl.registerLazySingleton(() => hive.GetHiveDetail(sl()));
  sl.registerLazySingleton(() => GetHiveHarvesters(sl()));
  sl.registerLazySingleton(() => GetHiveSchedules(sl()));
  sl.registerLazySingleton(() => AddHive(sl()));
  sl.registerLazySingleton(() => UpdateHive(sl()));
  sl.registerLazySingleton(() => DeleteHive(sl()));
  sl.registerLazySingleton(() => SetHarvestSchedule(sl()));
  sl.registerLazySingleton(() => RecordHarvest(sl()));
  sl.registerLazySingleton(() => UploadImage(sl()));
  sl.registerLazySingleton<HiveRepository>(
    () => HiveRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<HiveRemoteDataSource>(
    () => HiveRemoteDataSourceImpl(sl()),
  );

  // ── Schedule ─────────────────────────────────────────
  sl.registerFactory(() => ScheduleBloc(getHarvestSchedules: sl()));
  sl.registerLazySingleton(() => GetHarvestSchedules(sl()));
  sl.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<ScheduleRemoteDataSource>(
    () => ScheduleRemoteDataSourceImpl(sl()),
  );

  // ── Map ──────────────────────────────────────────────
  sl.registerFactory(
    () => MapBloc(getHives: sl(), getHiveDetail: sl()),
  );
  sl.registerLazySingleton(() => GetHives(sl()));
  sl.registerLazySingleton(() => GetHiveDetail(sl()));
  sl.registerLazySingleton<MapRepository>(
    () => MapRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<MapRemoteDataSource>(
    () => MapRemoteDataSourceImpl(sl()),
  );

  // ── Core ─────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton(() => ApiClient());

  // ── External ─────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() => FirebaseMessaging.instance);
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());
  sl.registerLazySingleton(
    () => FirebaseMessagingService(sl(), sl(), sl(), sl()),
  );
  await sl<FirebaseMessagingService>().init();

  // Wire 401 handler: setiap request yang return 401 → dispatch AuthSessionExpired
  sl<ApiClient>().onUnauthorized = () {
    sl<AuthBloc>().add(const AuthSessionExpired());
  };
}
