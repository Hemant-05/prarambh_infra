import 'package:get_it/get_it.dart';
import 'package:prarambh_infra/data/datasources/remote/api_client.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_provider.dart';

// --- Core & External ---
import 'core/network/dio_client.dart';
// --- Auth ---
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

// --- Admin Dashboard (Previous) ---
import 'package:prarambh_infra/features/admin/data/repositories/admin_repository.dart';
import 'package:prarambh_infra/features/admin/data/repositories/admin_advisor_repository.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_advisor_provider.dart';
import 'package:prarambh_infra/features/admin/data/repositories/admin_document_repository.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_document_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ---------------------------------------------------------------------------
  // 1. Providers / State Management (Register as Factory)
  // ---------------------------------------------------------------------------
  sl.registerFactory(() => AuthProvider(authRepository: sl()));
  sl.registerFactory(() => AdminProvider(adminRepository: sl()));

  // NEW ADDITIONS
  sl.registerFactory(() => AdminAdvisorProvider(repository: sl()));
  sl.registerFactory(() => AdminDocumentProvider(repository: sl()));

  // ---------------------------------------------------------------------------
  // 2. Repositories (Register as LazySingleton)
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton(() => AuthRepository(apiClient: sl()));
  sl.registerLazySingleton(() => AdminRepository(apiClient: sl()));

  // NEW ADDITIONS
  sl.registerLazySingleton(() => AdminAdvisorRepository(apiClient: sl()));
  sl.registerLazySingleton(() => AdminDocumentRepository(apiClient: sl()));

  // ---------------------------------------------------------------------------
  // 3. Core Network
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton(() => DioClient());
  sl.registerLazySingleton(() => ApiClient(sl<DioClient>().dio));
}