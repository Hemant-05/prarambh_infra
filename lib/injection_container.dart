import 'package:get_it/get_it.dart';
import 'package:prarambh_infra/data/datasources/remote/api_client.dart';
import 'package:prarambh_infra/features/admin/data/repositories/admin_attendance_repository.dart';
import 'package:prarambh_infra/features/admin/data/repositories/admin_contest_repository.dart';
import 'package:prarambh_infra/features/admin/data/repositories/admin_deal_repository.dart';
import 'package:prarambh_infra/features/admin/data/repositories/admin_lead_repository.dart';
import 'package:prarambh_infra/features/admin/data/repositories/admin_leaderboard_repository.dart';
import 'package:prarambh_infra/features/admin/data/repositories/admin_profile_repository.dart';
import 'package:prarambh_infra/features/admin/data/repositories/admin_project_repository.dart';
import 'package:prarambh_infra/features/admin/data/repositories/admin_recruitment_repository.dart';
import 'package:prarambh_infra/features/admin/data/repositories/admin_team_repository.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_attendance_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_contest_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_deal_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_lead_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_leaderboard_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_profile_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_project_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_recruitment_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_team_provider.dart';
import 'package:prarambh_infra/features/advisor/data/repositories/advisor_attendance_repository.dart';
import 'package:prarambh_infra/features/advisor/data/repositories/advisor_contest_repository.dart';
import 'package:prarambh_infra/features/advisor/data/repositories/advisor_document_repository.dart';
import 'package:prarambh_infra/features/advisor/data/repositories/advisor_lead_repository.dart';
import 'package:prarambh_infra/features/advisor/data/repositories/advisor_profile_repository.dart';
import 'package:prarambh_infra/features/advisor/data/repositories/advisor_project_repository.dart';
import 'package:prarambh_infra/features/advisor/data/repositories/advisor_repository.dart';
import 'package:prarambh_infra/features/advisor/data/repositories/advisor_team_repository.dart';
import 'package:prarambh_infra/features/advisor/presentation/providers/advisor_attendance_provider.dart';
import 'package:prarambh_infra/features/advisor/presentation/providers/advisor_contest_provider.dart';
import 'package:prarambh_infra/features/advisor/presentation/providers/advisor_dashboard_provider.dart';
import 'package:prarambh_infra/features/advisor/presentation/providers/advisor_document_provider.dart';
import 'package:prarambh_infra/features/advisor/presentation/providers/advisor_lead_provider.dart';
import 'package:prarambh_infra/features/advisor/presentation/providers/advisor_leaderboard_provider.dart';
import 'package:prarambh_infra/features/advisor/data/repositories/advisor_leaderboard_repository.dart';
import 'package:prarambh_infra/features/advisor/presentation/providers/advisor_profile_provider.dart';
import 'package:prarambh_infra/features/advisor/presentation/providers/advisor_project_provider.dart';
import 'package:prarambh_infra/features/advisor/presentation/providers/advisor_team_provider.dart';
import 'package:prarambh_infra/features/recruitment/data/repositories/recruitment_repository.dart';
import 'package:prarambh_infra/features/recruitment/presentation/providers/advisor_registration_provider.dart';
import 'package:prarambh_infra/features/recruitment/presentation/providers/recruitment_provider.dart';

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

  sl.registerFactory(() => AuthProvider(authRepository: sl()));
  sl.registerFactory(() => AdminProvider(adminRepository: sl()));

  sl.registerFactory(() => AdminAdvisorProvider(repository: sl()));
  sl.registerFactory(() => AdminDocumentProvider(repository: sl()));

  sl.registerLazySingleton(() => AuthRepository(apiClient: sl()));
  sl.registerLazySingleton(() => AdvisorRegistrationProvider(repository: sl()));
  sl.registerLazySingleton(() => AdminRepository(apiClient: sl()));

  sl.registerLazySingleton(() => AdminAdvisorRepository(apiClient: sl()));
  sl.registerLazySingleton(() => AdminDocumentRepository(apiClient: sl()));

  sl.registerFactory(() => AdminContestProvider(repository: sl()));
  sl.registerLazySingleton(() => AdminContestRepository(apiClient: sl()));

  sl.registerFactory(()=> AdminLeaderboardProvider(repository: sl()));
  sl.registerLazySingleton(() => AdminLeaderboardRepository(apiClient: sl()));

  sl.registerFactory(() => AdminAttendanceProvider(repository: sl()));
  sl.registerLazySingleton(() => AdminAttendanceRepository(apiClient: sl()));

  sl.registerFactory(() => AdminRecruitmentProvider(repository: sl()));
  sl.registerLazySingleton(() => AdminRecruitmentRepository(apiClient: sl()));

  sl.registerFactory(() => AdminTeamProvider(repository: sl()));
  sl.registerLazySingleton(() => AdminTeamRepository(apiClient: sl()));

  sl.registerFactory(() => AdminProjectProvider(repository: sl()));
  sl.registerLazySingleton(() => AdminProjectRepository(apiClient: sl()));

  sl.registerFactory(() => AdminLeadProvider(repository: sl()));
  sl.registerLazySingleton(() => AdminLeadRepository(apiClient: sl()));

  sl.registerFactory(() => AdminProfileProvider(repository: sl()));
  sl.registerLazySingleton(() => AdminProfileRepository(apiClient: sl()));

  sl.registerFactory(() => AdvisorDashboardProvider(repository: sl()));
  sl.registerLazySingleton(() => AdvisorRepository(apiClient: sl()));

  sl.registerFactory(() => RecruitmentProvider(repository: sl()));
  sl.registerLazySingleton(() => RecruitmentRepository(apiClient: sl()));

  sl.registerFactory(() => AdvisorDocumentProvider(repository: sl()));
  sl.registerLazySingleton(() => AdvisorDocumentRepository(apiClient: sl()));

  sl.registerFactory(() => AdminDealProvider(repository: sl()));
  sl.registerLazySingleton(() => AdminDealRepository(apiClient: sl()));

  sl.registerFactory(() => AdvisorLeadProvider(repository: sl()));
  sl.registerLazySingleton(() => AdvisorLeadRepository(apiClient: sl()));

  sl.registerFactory(() => AdvisorContestProvider(repository: sl()));
  sl.registerLazySingleton(() => AdvisorContestRepository(apiClient: sl()));

  sl.registerFactory(() => AdvisorAttendanceProvider(repository: sl()));
  sl.registerLazySingleton(() => AdvisorAttendanceRepository(apiClient: sl()));

  sl.registerFactory(() => AdvisorLeaderboardProvider(repository: sl()));
  sl.registerLazySingleton(() => AdvisorLeaderboardRepository(apiClient: sl()));

  sl.registerFactory(()=> AdvisorProjectProvider(repository: sl()));
  sl.registerLazySingleton(() => AdvisorProjectRepository(apiClient: sl()));

  sl.registerFactory(() => AdvisorTeamProvider(repository: sl()));
  sl.registerLazySingleton(()=> AdvisorTeamRepository(apiClient: sl()));

  sl.registerFactory(() => AdvisorProfileProvider(repository: sl()));
  sl.registerLazySingleton(() => AdvisorProfileRepository(apiClient: sl()));
  // ---------------------------------------------------------------------------
  // 3. Core Network
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton(() => DioClient());
  sl.registerLazySingleton(() => ApiClient(sl<DioClient>().dio));
}