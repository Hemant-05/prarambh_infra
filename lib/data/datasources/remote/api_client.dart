import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // ==========================================
  // 1. Authentication
  // ==========================================
  @POST("/login")
  Future<dynamic> loginUser(@Body() dynamic body);

  @POST("/advisor/login")
  Future<dynamic> loginAdvisor(@Body()  dynamic body);

  @POST("/register")
  Future<dynamic> registerUser(@Body() dynamic body);

  @POST("/password/forgot")
  Future<dynamic> requestPasswordReset(@Body() dynamic body);

  @POST("/password/verify-otp")
  Future<dynamic> verifyOtp(@Body() dynamic body);

  @POST("/password/reset")
  Future<dynamic> resetPassword(@Body() dynamic body);

  // ==========================================
  // 2. User Profiles & KYC
  // ==========================================
  @GET("/profile")
  Future<dynamic> getProfile(@Query("user_id") int userId);

  @POST("/profile/update")
  Future<dynamic> updateProfile(@Body() dynamic body);

  @MultiPart()
  @POST("/profile/photo")
  Future<dynamic> uploadProfilePhoto(
      @Part(name: "photo") File photo,
      @Part(name: "user_id") String userId,
      );

  @MultiPart()
  @POST("/profile/kyc")
  Future<dynamic> uploadKycDocument(
      @Part(name: "document") File document,
      @Part(name: "user_id") String userId,
      @Part(name: "document_name") String documentName,
      );

  // ==========================================
  // 3. Inventory (Projects & Units)
  // ==========================================
  @GET("/projects")
  Future<dynamic> getAllProjects();

  @GET("/projects/details")
  Future<dynamic> getProjectDetails(@Query("id") int projectId);

  @MultiPart()
  @POST("/projects/add")
  Future<dynamic> addProject(
      @Part(name: "project_name") String projectName,
      @Part(name: "developer_name") String developerName,
      @Part(name: "city") String city,
      @Part(name: "full_address") String fullAddress,
      @Part(name: "status") String status,
      @Part(name: "project_type") String projectType,
      @Part(name: "construction_status") String constructionStatus,
      @Part(name: "market_value") String marketValue,
      @Part(name: "total_plots") String totalPlots,
      @Part(name: "build_area") String buildArea,
      @Part(name: "rera_number") String reraNumber,
      @Part(name: "location") String location,
      @Part(name: "rate_per_sqft") String ratePerSqft,
      @Part(name: "budget_range") String budgetRange,
      @Part(name: "description") String description,
      @Part(name: "rera_approved") String reraApproved,
      @Part(name: "amenities") String amenities,
      @Part(name: "specialties") String specialties,
      @Part(name: "video") File? video,
      @Part(name: "brochure") File? brochure,
      @Part(name: "images[]") List<File> images,
      );

  @POST("/projects/update")
  Future<dynamic> updateProject(@Body() dynamic body);

  @POST("/projects/delete")
  Future<dynamic> deleteProject(@Body() dynamic body);

  @GET("/units")
  Future<dynamic> getUnits(@Query("project_id") int projectId);

  @POST("/units/add")
  Future<dynamic> addUnit(@Body() dynamic body);

  @POST("/units/update")
  Future<dynamic> updateUnit(@Body() dynamic body);

  @POST("/units/delete")
  Future<dynamic> deleteUnit(@Body() dynamic body);

  // ==========================================
  // 4. CRM (Leads)
  // ==========================================
  @GET("/leads")
  Future<dynamic> getLeads(
      @Query("user_id") int userId,
      @Query("role") String role,
      @Query("stage") String? stage,
      );

  @POST("/leads/create")
  Future<dynamic> createLead(@Body() dynamic body);

  @POST("/leads/update-details")
  Future<dynamic> updateLeadDetails(@Body() dynamic body);

  @POST("/leads/log-interaction")
  Future<dynamic> logInteraction(@Body() dynamic body);

  @POST("/leads/delete")
  Future<dynamic> deleteLead(@Body() dynamic body);

  // ==========================================
  // 5. Bookings & Payments
  // ==========================================
  @GET("/bookings")
  Future<dynamic> getBookings();

  @POST("/bookings/create")
  Future<dynamic> createBooking(@Body() dynamic body);

  @POST("/bookings/update-status")
  Future<dynamic> updateBookingStatus(@Body() dynamic body);

  @GET("/payments")
  Future<dynamic> getPayments(@Query("booking_id") int bookingId);

  @POST("/payments/add")
  Future<dynamic> addPayment(@Body() dynamic body);

  @POST("/payments/update-details")
  Future<dynamic> updatePaymentDetails(@Body() dynamic body);

  @POST("/payments/update-status")
  Future<dynamic> updatePaymentStatus(@Body() dynamic body);

  @POST("/payments/delete")
  Future<dynamic> deletePayment(@Body() dynamic body);

  // ==========================================
  // 6. Meetings & Attendance
  // ==========================================
  @GET("/meetings")
  Future<dynamic> getMeetings();

  @POST("/meetings/create")
  Future<dynamic> createMeeting(@Body() dynamic body);

  @POST("/meetings/update")
  Future<dynamic> updateMeeting(@Body() dynamic body);

  @POST("/meetings/delete")
  Future<dynamic> deleteMeeting(@Body() dynamic body);

  @GET("/attendance")
  Future<dynamic> getAttendance(@Query("user_id") int userId);

  @POST("/attendance/checkin")
  Future<dynamic> checkinAttendance(@Body() dynamic body);

  @POST("/attendance/checkout")
  Future<dynamic> checkoutAttendance(@Body() dynamic body);

  @POST("/attendance/delete")
  Future<dynamic> deleteAttendance(@Body() dynamic body);

  // ==========================================
  // 7. Team, Promotions & Contests
  // ==========================================
  @GET("/team")
  Future<dynamic> getTeamHierarchy(
      @Query("user_id") int userId,
      @Query("view") String view,
      );

  @POST("/team/assign")
  Future<dynamic> assignTeamMember(@Body() dynamic body);

  @POST("/team/remove")
  Future<dynamic> removeTeamMember(@Body() dynamic body);

  @GET("/promotions/status")
  Future<dynamic> getPromotionStatus(@Query("user_id") int userId);

  @POST("/promotions/upgrade")
  Future<dynamic> upgradePromotion(@Body() dynamic body);

  @GET("/contests")
  Future<dynamic> getContests();

  @POST("/contests/create")
  Future<dynamic> createContest(@Body() dynamic body);

  @POST("/contests/update")
  Future<dynamic> updateContest(@Body() dynamic body);

  @POST("/contests/delete")
  Future<dynamic> deleteContest(@Body() dynamic body);

  // ==========================================
  // 8. Operations (Dashboard & Docs)
  // ==========================================
  @GET("/dashboard")
  Future<dynamic> getDashboardData(
      @Query("user_id") int userId,
      @Query("role") String role,
      );

  @GET("/documents")
  Future<dynamic> getDocuments();

  @MultiPart()
  @POST("/documents/upload")
  Future<dynamic> uploadDocument(
      @Part(name: "document") File document,
      @Part(name: "uploader_id") String uploaderId,
      @Part(name: "document_name") String documentName,
      @Part(name: "category") String category,
      );

  @POST("/documents/update")
  Future<dynamic> updateDocumentMetadata(@Body() dynamic body);

  @POST("/documents/delete")
  Future<dynamic> deleteDocument(@Body() dynamic body);
}