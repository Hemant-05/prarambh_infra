import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

// Replace with your actual base URL or environment variable
@RestApi(baseUrl: "http://yourdomain.com/api/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // --- 1. Authentication APIs ---

  @POST("register.php")
  Future<Map<String, dynamic>> registerUser(@Body() Map<String, dynamic> body);

  @POST("login.php")
  Future<Map<String, dynamic>> loginUser(@Body() Map<String, dynamic> body);

  @POST("forgot_password.php")
  Future<Map<String, dynamic>> requestPasswordReset(@Body() Map<String, dynamic> body);

  @POST("verify_otp.php")
  Future<Map<String, dynamic>> verifyOtp(@Body() Map<String, dynamic> body);

  @POST("reset_password.php")
  Future<Map<String, dynamic>> resetPassword(@Body() Map<String, dynamic> body);

  // --- 2. CRM & Leads APIs ---

  @POST("add_lead.php")
  Future<Map<String, dynamic>> addLead(@Body() Map<String, dynamic> body);

  @POST("get_leads.php")
  Future<Map<String, dynamic>> getLeads(@Body() Map<String, dynamic> body);

  @POST("update_lead_stage.php")
  Future<Map<String, dynamic>> updateLeadStage(@Body() Map<String, dynamic> body);

  // --- 3. Inventory & Operations APIs ---

  @GET("get_projects.php")
  Future<Map<String, dynamic>> getProjects();

  @GET("get_meetings.php")
  Future<Map<String, dynamic>> getMeetings(@Query("user_id") int userId);

  @POST("mark_attendance.php")
  Future<Map<String, dynamic>> markAttendance(@Body() Map<String, dynamic> body);

  // --- 4. Transactions & Uploads APIs ---

  @POST("create_booking.php")
  Future<Map<String, dynamic>> createBooking(@Body() Map<String, dynamic> body);

  @GET("manager_dashboard.php")
  Future<Map<String, dynamic>> getManagerDashboard(@Query("user_id") int userId);

  // Document Upload (Requires Multipart)
  @MultiPart()
  @POST("upload_document.php")
  Future<Map<String, dynamic>> uploadDocument(
      @Part(name: "document") File document,
      @Part(name: "uploader_id") int uploaderId,
      @Part(name: "document_name") String documentName,
      @Part(name: "category") String? category,
      @Part(name: "project_id") int? projectId,
      );
}