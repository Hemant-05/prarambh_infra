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
  @POST("/auth/user/login")
  Future<dynamic> loginUser(@Body() dynamic body);

  @POST("/auth/advisor/login")
  Future<dynamic> loginAdvisor(@Body() dynamic body);

  // ==========================================
  // 2. User Management
  // ==========================================
  @POST("/user/register")
  Future<dynamic> registerUser(@Body() dynamic body);

  @GET("/user/{id}")
  Future<dynamic> getSingleUser(@Path("id") String id);

  @POST("/user/update/{id}")
  Future<dynamic> updateUserProfile(
    @Path("id") String id,
    @Body() dynamic body,
  );

  @DELETE("/user/delete/{id}")
  Future<dynamic> deleteUser(@Path("id") String id);

  // ==========================================
  // 3. Advisor Management
  // ==========================================
  @MultiPart()
  @POST("/advisor/register")
  Future<dynamic> registerAdvisor(
    @Part(name: "full_name") String fullName,
    @Part(name: "email") String email,
    @Part(name: "phone") String phone,
    @Part(name: "designation") String designation,
    @Part(name: "father_name") String fatherName,
    @Part(name: "date_of_birth") String dob,
    @Part(name: "gender") String gender,
    @Part(name: "nomineename") String nomineeName,
    @Part(name: "nomineephone") String nomineePhone,
    @Part(name: "relationship") String relationship,
    @Part(name: "occupation") String occupation,
    @Part(name: "aadhaar_number") String aadhaar,
    @Part(name: "pan_number") String pan,
    @Part(name: "bank_name") String bankName,
    @Part(name: "account_number") String accNumber,
    @Part(name: "ifsc_code") String ifsc,
    @Part(name: "address") String address,
    @Part(name: "city") String city,
    @Part(name: "state") String state,
    @Part(name: "pincode") String pincode,
    @Part(name: "leader_code") String leaderCode,
    @Part(name: "addresscard_front_photo") File aadharFront,
    @Part(name: "addresscard_back_photo") File aadharBack,
    @Part(name: "pancard_photo") File panPhoto,
    @Part(name: "pancard_back_photo") File panBackPhoto,
    @Part(name: "profile_photo") File profilePhoto,
  );

  @POST("/advisor/approve/{id}")
  Future<dynamic> approveAdvisor(@Path("id") String id);

  @GET("/advisor/all")
  Future<dynamic> getAllAdvisors(@Query("status") String? status);

  @GET("/advisor/{id}")
  Future<dynamic> getSingleAdvisor(@Path("id") String id);

  @POST("/advisor/update/{id}")
  Future<dynamic> updateAdvisor(@Path("id") String id, @Body() dynamic body);

  @POST("/advisor/status/{id}")
  Future<dynamic> changeAdvisorStatus(
    @Path("id") String id,
    @Body() dynamic body,
  );

  @DELETE("/advisor/delete/{id}")
  Future<dynamic> deleteAdvisor(@Path("id") String id);

  // ==========================================
  // 4. Password Reset
  // ==========================================
  @POST("/password/forgot")
  Future<dynamic> requestPasswordReset(@Body() dynamic body);

  @POST("/password/verify-otp")
  Future<dynamic> verifyOtp(@Body() dynamic body);

  @POST("/password/reset")
  Future<dynamic> resetPassword(@Body() dynamic body);

  // ==========================================
  // 5. Projects Inventory
  // ==========================================
  @MultiPart()
  @POST("/projects/add")
  Future<dynamic> addProject(
    @Part(name: "project_name") String projectName,
    @Part(name: "developer_name") String developerName,
    @Part(name: "description") String description,
    @Part(name: "rera_number") String reraNumber,
    @Part(name: "project_type") String projectType,
    @Part(name: "construction_status") String constructionStatus,
    @Part(name: "full_address") String fullAddress,
    @Part(name: "location") String location,
    @Part(name: "city") String city,
    @Part(name: "market_value") String marketValue,
    @Part(name: "total_plots") String totalPlots,
    @Part(name: "build_area") String buildArea,
    @Part(name: "rate_per_sqft") String ratePerSqft,
    @Part(name: "budget_range") String budgetRange,
    @Part(name: "amenities") String amenities,
    @Part(name: "specialties") String specialties,
    @Part(name: "video_file") File? videoFile,
    @Part(name: "brochure_file") File? brochureFile,
    @Part(name: "project_images[]") List<File> projectImages,
  );

  @GET("/projects")
  Future<dynamic> getAllProjects();

  @GET("/projects/{id}")
  Future<dynamic> getSingleProject(@Path("id") String id);

  @MultiPart()
  @POST("/projects/update/{id}")
  Future<dynamic> updateProject(
    @Path("id") String id,
    @Part(name: "project_name") String? projectName,
    @Part(name: "developer_name") String? developerName,
    @Part(name: "description") String? description,
    @Part(name: "project_type") String? projectType,
    @Part(name: "construction_status") String? constructionStatus,
    @Part(name: "full_address") String? fullAddress,
    @Part(name: "location") String? location,
    @Part(name: "city") String? city,
    @Part(name: "market_value") String? marketValue,
    @Part(name: "total_plots") String? totalPlots,
    @Part(name: "build_area") String? buildArea,
    @Part(name: "rate_per_sqft") String? ratePerSqft,
    @Part(name: "specialties") String? specialties,
    @Part(name: "amenities") String? amenities,
    @Part(name: "budget_range") String? budgetRange,
    @Part(name: "rera_number") String? reraNumber,
    @Part(name: "status") String? status,
    @Part(name: "video") File? videoFile,
    @Part(name: "brochure_file") File? brochureFile,
    @Part(name: "project_images[]") List<File>? projectImages,
  );

  @DELETE("/projects/delete/{id}")
  Future<dynamic> deleteProject(@Path("id") String id);

  // ==========================================
  // 6. Units Inventory
  // ==========================================
  @POST("/units/add")
  Future<dynamic> addUnit(@Body() dynamic body);

  @POST("/units/add-multiple")
  Future<dynamic> addMultipleUnits(@Body() dynamic body);

  @GET("/units")
  Future<dynamic> getUnits(@Query("project_id") String? projectId);

  @GET("/units/{id}")
  Future<dynamic> getSingleUnit(@Path("id") String id);

  @PUT("/units/update/{id}")
  Future<dynamic> updateUnit(@Path("id") String id, @Body() dynamic body);

  @DELETE("/units/delete/{id}")
  Future<dynamic> deleteUnit(@Path("id") String id);

  // ==========================================
  // 7. Document Management
  // ==========================================
  @MultiPart()
  @POST("/documents/add")
  Future<dynamic> addDocument(
    @Part(name: "name") String name,
    @Part(name: "category") String category,
    @Part(name: "user_id") String? userId,
    @Part(name: "document_file") File documentFile,
  );

  @GET("/documents")
  Future<dynamic> getDocuments(
    @Query("user_id") String? userId,
    @Query("category") String? category,
    @Query("general") String? general,
  );

  @GET("/documents/{id}")
  Future<dynamic> getSingleDocument(@Path("id") String id);

  @MultiPart()
  @POST("/documents/update/{id}")
  Future<dynamic> updateDocument(
    @Path("id") String id,
    @Part(name: "name") String? name,
    @Part(name: "document_file") File? documentFile,
  );

  @DELETE("/documents/delete/{id}")
  Future<dynamic> deleteDocument(@Path("id") String id);

  // ==========================================
  // 8. Lead Management & Priority
  // ==========================================
  @POST("/leads/add")
  Future<dynamic> addLead(@Body() dynamic body);

  // Can be JSON or FormData (for site visit photos)
  @POST("/leads/update/{id}")
  Future<dynamic> updateLead(@Path("id") String id, @Body() dynamic body);

  @GET("/leads")
  Future<dynamic> getLeads(@Query("advisor_code") String? advisorCode);

  @GET("/leads/{id}")
  Future<dynamic> getSingleLead(@Path("id") String id);

  @POST("/leads/priority/add/{id}")
  Future<dynamic> addLeadToPriority(@Path("id") String id);

  @GET("/leads/priority")
  Future<dynamic> getPriorityLeads();

  @POST("/leads/priority/remove/{id}")
  Future<dynamic> removeLeadFromPriority(@Path("id") String id);

  @DELETE("/leads/delete/{id}")
  Future<dynamic> deleteLead(@Path("id") String id);

  // ==========================================
  // 9. Deal Management (New)
  // ==========================================
  @MultiPart()
  @POST("/deals/add")
  Future<dynamic> addDeal(
    @Part(name: "client_name") String clientName,
    @Part(name: "client_number") String clientNumber,
    @Part(name: "property_id") String propertyId,
    @Part(name: "client_email") String clientEmail,
    @Part(name: "notes") String notes,
    @Part(name: "payment_mode") String paymentMode,
    @Part(name: "total_payment_amount") String totalAmount,
    @Part(name: "payment_plan") String paymentPlan,
    @Part(name: "client_adhar_front") File aadharFront,
  );

  @POST("/deals/update/{id}")
  Future<dynamic> updateDeal(@Path("id") String id, @Body() dynamic body);

  @GET("/deals")
  Future<dynamic> getAllDeals();

  @DELETE("/deals/delete/{id}")
  Future<dynamic> deleteDeal(@Path("id") String id);

  // ==========================================
  // 10. Meetings & Attendance
  // ==========================================
  @POST("/meetings/add")
  Future<dynamic> addMeeting(@Body() dynamic body);

  @MultiPart()
  @POST("/attendance/check-in")
  Future<dynamic> checkInAttendance(
    @Part(name: "meeting_id") String meetingId,
    @Part(name: "advisor_id") String advisorId,
    @Part(name: "check_in_photo") File photo,
  );

  @MultiPart()
  @POST("/attendance/check-out")
  Future<dynamic> checkOutAttendance(
    @Part(name: "meeting_id") String meetingId,
    @Part(name: "advisor_id") String advisorId,
    @Part(name: "check_out_photo") File photo,
  );

  @GET("/meetings/{id}")
  Future<dynamic> getSingleMeeting(@Path("id") String id);

  // ==========================================
  // 11. Contests
  // ==========================================
  @MultiPart()
  @POST("/contests/add")
  Future<dynamic> addContest(
    @Part(name: "title") String title,
    @Part(name: "start_date") String startDate,
    @Part(name: "end_date") String endDate,
    @Part(name: "reward_name") String rewardName,
    @Part(name: "rules") String rules,
    @Part(name: "reward_image") File image,
  );

  @POST("/contests/join")
  Future<dynamic> joinContest(@Body() dynamic body);

  @GET("/contests")
  Future<dynamic> getContests();

  // ==========================================
  // 12. Performance & Leaderboard
  // ==========================================
  @GET("/leaderboard")
  Future<dynamic> getLeaderboard();

  @POST("/evaluate-level/{id}")
  Future<dynamic> evaluateLevel(@Path("id") String id);

  // ==========================================
  // 13. User Property Reselling
  // ==========================================
  @POST("/user-property/add")
  Future<dynamic> addUserProperty(@Body() dynamic body);

  @POST("/user-property/verify/{id}")
  Future<dynamic> verifyUserProperty(
    @Path("id") String id,
    @Body() dynamic body,
  );

  @GET("/user-property/my/{id}")
  Future<dynamic> getMyProperties(@Path("id") String id);
}
