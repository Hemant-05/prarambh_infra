import 'package:get_it/get_it.dart';
import 'package:prarambh_infra/core/network/dio_client.dart';
import 'package:prarambh_infra/data/datasources/remote/api_client.dart';
import 'package:prarambh_infra/features/admin/data/repository/admin_repository.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_provider.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

// Create a global instance of GetIt
final sl = GetIt.instance;

Future<void> init() async {
  // --- 1. Providers ---
  sl.registerFactory(() => AuthProvider(authRepository: sl()));
  sl.registerFactory(() => AdminProvider(adminRepository: sl())); // ADD THIS

  // --- 2. Repositories ---
  sl.registerLazySingleton(() => AuthRepository(apiClient: sl()));
  sl.registerLazySingleton(() => AdminRepository(apiClient: sl())); // ADD THIS

  // --- 3. Core ---
  sl.registerLazySingleton(() => DioClient());
  sl.registerLazySingleton(() => ApiClient(sl<DioClient>().dio));
}