import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../features/client/data/models/enquiry_model.dart';

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
  // 2. User/Client Management
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

  @GET("/advisor/profile/{id}")
  Future<dynamic> getAdvisorProfile(@Path("id") String id);

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
  // 4. Password Reset (OTP)
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
    @Part(name: "video_file") File? videoFile,
    @Part(name: "brochure_file") File? brochureFile,
    @Part(name: "project_images[]") List<File>? projectImages,
  );

  @DELETE("/projects/delete/{id}")
  Future<dynamic> deleteProject(@Path("id") String id);

  // ==========================================
  // 6. Units Inventory & CSV Uploads
  // ==========================================
  @MultiPart()
  @POST("/units/add")
  Future<dynamic> addUnit(
    @Part(name: "project_id") String projectId,
    @Part(name: "tower_name") String towerName,
    @Part(name: "floor_number") String floorNumber,
    @Part(name: "unit_number") String unitNumber,
    @Part(name: "configuration") String configuration,
    @Part(name: "property_type") String propertyType,
    @Part(name: "sale_category") String saleCategory,
    @Part(name: "facing") String facing,
    @Part(name: "Location") String location,
    @Part(name: "plot_number") String plotNumber,
    @Part(name: "plot_dimensions") String plotDimensions,
    @Part(name: "area_sqft") String areaSqft,
    @Part(name: "rate_per_sqft") String ratePerSqft,
    @Part(name: "size") String size,
    @Part(name: "availability_status") String availabilityStatus,
    @Part(name: "unit_images[]") List<File>? unitImages,
  );

  @POST("/units/add-multiple")
  Future<dynamic> addMultipleUnits(@Body() dynamic body);

  @MultiPart()
  @POST("/units/bulk-upload")
  Future<dynamic> bulkUploadUnits(
    @Part(name: "project_id") String projectId,
    @Part(name: "file") File csvFile,
  );

  @GET("/units")
  Future<dynamic> getUnits(@Query("project_id") String? projectId);

  @GET("/units/{id}")
  Future<dynamic> getSingleUnit(@Path("id") String id);

  @GET("/units/sales/{id}")
  Future<dynamic> getUnitSales(@Path("id") String id);

  @MultiPart()
  @POST("/units/update/{id}")
  Future<dynamic> updateUnit(
    @Path("id") String id,
    @Part(name: "project_id") String? projectId,
    @Part(name: "tower_name") String? towerName,
    @Part(name: "floor_number") String? floorNumber,
    @Part(name: "unit_number") String? unitNumber,
    @Part(name: "configuration") String? configuration,
    @Part(name: "property_type") String? propertyType,
    @Part(name: "sale_category") String? saleCategory,
    @Part(name: "facing") String? facing,
    @Part(name: "Location") String? location,
    @Part(name: "plot_number") String? plotNumber,
    @Part(name: "plot_dimensions") String? plotDimensions,
    @Part(name: "area_sqft") String? areaSqft,
    @Part(name: "rate_per_sqft") String? ratePerSqft,
    @Part(name: "size") String? size,
    @Part(name: "availability_status") String? availabilityStatus,
    @Part(name: "unit_images[]") List<File>? unitImages,
  );

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
  );

  @GET("/documents/{id}")
  Future<dynamic> getSingleDocument(@Path("id") String id);

  @MultiPart()
  @POST("/documents/update/{id}")
  Future<dynamic> updateDocument(
    @Path("id") String id,
    @Part(name: "name") String? name,
    @Part(name: "category") String? category,
    @Part(name: "document_file") File? documentFile,
  );

  @DELETE("/documents/delete/{id}")
  Future<dynamic> deleteDocument(@Path("id") String id);

  // ==========================================
  // 8. Lead Management & Priority
  // ==========================================
  @POST("/leads/add")
  Future<dynamic> addLead(@Body() dynamic body);

  @POST("/leads/interested")
  Future<dynamic> createInterestedLead(@Body() InterestedLeadRequest body);

  @MultiPart()
  @POST("/leads/update/{id}")
  Future<dynamic> updateLead(@Path("id") String id, @Body() dynamic body);

  @GET("/advisor/assign-list")
  Future<dynamic> getAdvisorsForAssignment();

  @POST("/leads/add-note/{id}")
  Future<dynamic> addLeadNote(@Path("id") String id, @Body() dynamic body);

  @POST("/leads/assign/{id}")
  Future<dynamic> assignLeadToAdvisor(
    @Path("id") String leadId,
    @Field("advisor_code") String advisorCode,
  );

  @GET("/leads")
  Future<dynamic> getLeads(
    @Query("advisor_code") String? advisorCode,
    @Query("stage") String? stage,
    @Query("source") String? source,
  );

  @GET("/leads/unassigned")
  Future<dynamic> getUnassignedLeads();

  @GET("/leads/{id}")
  Future<dynamic> getSingleLead(@Path("id") String id);

  @POST("/leads/priority/add/{id}")
  Future<dynamic> addLeadToPriority(@Path("id") String id);

  @GET("/leads/priority")
  Future<dynamic> getPriorityLeads(@Query("advisor_code") String? advisorCode);

  @POST("/leads/priority/remove/{id}")
  Future<dynamic> removeLeadFromPriority(@Path("id") String id);

  @DELETE("/leads/delete/{id}")
  Future<dynamic> deleteLead(@Path("id") String id);

  // ==========================================
  // 9. Deal Management
  // ==========================================
  @MultiPart()
  @POST("/deals/add")
  Future<dynamic> createDeal(
    @Part(name: "client_name") String clientName,
    @Part(name: "client_number") String clientNumber,
    @Part(name: "client_email") String? clientEmail,
    @Part(name: "advisor_code") String advisorCode,
    @Part(name: "stage") String stage,
    @Part(name: "deal_status") String dealStatus,
    @Part(name: "lead_id") String leadId,
    @Part(name: "property_id") String propertyId,
    @Part(name: "unit_id") String unitId,
    @Part(name: "payment_amount") String? paymentAmount,
    @Part(name: "token_amount") String? tokenAmount,
    @Part(name: "token_payment_mode") String? tokenPaymentMode,
    @Part(name: "token_date") String? tokenDate,
    @Part(name: "client_adhar_front") File? clientAdharFront,
    @Part(name: "client_adhar_back") File? clientAdharBack,
    @Part(name: "client_pan_front") File? clientPanFront,
    @Part(name: "client_pan_back") File? clientPanBack,
    @Part(name: "notes") String? notes,
    @Part(name: "installments") String? installments,
    @Part(name: "doc_titles[]") List<String>? docTitles,
    @Part(name: "doc_files[]") List<File>? docFiles,
  );

  @POST("/deals/update/{id}")
  Future<dynamic> updateDeal(@Path("id") String dealId, @Body() dynamic data);

  @POST("/deals/add-note/{id}")
  Future<dynamic> addDealNote(@Path("id") String id, @Body() dynamic body);

  @GET("/deals")
  Future<dynamic> getAllDeals(@Query("advisor_code") String? advisorCode);

  @GET("/deals/{id}")
  Future<dynamic> getSingleDeal(@Path("id") String id);

  @DELETE("/deals/delete/{id}")
  Future<dynamic> deleteDeal(@Path("id") String id);

  // ==========================================
  // 10. Meetings & Attendance
  // ==========================================
  @POST("/meetings/add")
  Future<dynamic> addMeeting(@Body() dynamic body);

  @PUT("/meetings/update/{id}")
  Future<dynamic> updateMeeting(@Path("id") String id, @Body() dynamic body);

  @GET("/meetings")
  Future<dynamic> getAllMeetings();

  @GET("/meetings/daily")
  Future<dynamic> getDailyMeetings(@Query("date") String? date);

  @GET("/meetings/{id}")
  Future<dynamic> getSingleMeeting(@Path("id") String id);

  @DELETE("/meetings/delete/{id}")
  Future<dynamic> deleteMeeting(@Path("id") String id);

  @GET("/attendance/daily")
  Future<dynamic> getDailyAttendance(@Query("date") String date);

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

  @MultiPart()
  @POST("/contests/update/{id}")
  Future<dynamic> updateContest(
    @Path("id") String id,
    @Part(name: "title") String? title,
    @Part(name: "reward_image") File? image,
  );

  @POST("/contests/join")
  Future<dynamic> joinContest(@Body() dynamic body);

  @GET("/contests")
  Future<dynamic> getContests();

  @GET("/contests/{id}")
  Future<dynamic> getSingleContest(@Path("id") String id);

  @DELETE("/contests/delete/{id}")
  Future<dynamic> deleteContest(@Path("id") String id);

  // ==========================================
  // 12. Performance, Promotions & Leaderboard
  // ==========================================
  @GET("/leaderboard")
  Future<dynamic> getLeaderboard(
    @Query("month") int? month,
    @Query("year") int? year,
  );

  @GET("/achievements/advisor/{advisorCode}")
  Future<dynamic> getAdvisorAchievements(
    @Path("advisorCode") String advisorCode,
  );

  @POST("/evaluate-level/{id}")
  Future<dynamic> evaluateLevel(@Path("id") String id);

  @POST("/promotions/evaluate/{id}")
  Future<dynamic> evaluateSinglePromotion(@Path("id") String id);

  @POST("/promotions/evaluate-company")
  Future<dynamic> evaluateCompanyPromotions();

  // ==========================================
  // 13. Dashboards & Analytics
  // ==========================================
  @GET("/admin/sales-analytics")
  Future<dynamic> getAdminSalesAnalytics();

  @GET("/admin/dashboard")
  Future<dynamic> getAdminDashboard(
    @Query("project_id") String? projectId,
  );

  @GET("/advisor/app-dashboard")
  Future<dynamic> getAdvisorDashboard(
    @Query("advisor_code") String advisorCode,
  );

  @GET("/inventory/dashboard")
  Future<dynamic> getInventoryDashboard(@Query("project_id") String? projectId);

  @GET("/recruitment/dashboard")
  Future<dynamic> getRecruitmentDashboard(@Query("leader_id") String? leaderId);

  @GET("/performance/dashboard")
  Future<dynamic> getPerformanceDashboard(
    @Query("advisor_code") String advisorCode,
  );

  // ==========================================
  // 14. Team Hierarchy & Activity
  // ==========================================
  @GET("/team/tree")
  Future<dynamic> getTeamTree(@Query("leader_id") String? leaderId);

  @GET("/team/advisor/{id}")
  Future<dynamic> getAdvisorTeam(@Path("id") String advisorId);

  @GET("/team/activity")
  Future<dynamic> getTeamActivity(
    @Query("advisor_code") String advisorCode,
    @Query("month") int? month,
    @Query("year") int? year,
  );

  // ==========================================
  // 15. Blogs
  // ==========================================
  @MultiPart()
  @POST("/blogs/add")
  Future<dynamic> addBlog(
    @Part(name: "title") String title,
    @Part(name: "description") String? content,
    @Part(name: "image") File? image,
  );

  @MultiPart()
  @POST("/blogs/update/{id}")
  Future<dynamic> updateBlog(
    @Path("id") String id,
    @Part(name: "title") String? title,
    @Part(name: "description") String? content,
    @Part(name: "image") File? image,
  );

  @GET("/blogs")
  Future<dynamic> getBlogs(@Query("status") String? status);

  @GET("/blogs/{id}")
  Future<dynamic> getSingleBlog(@Path("id") String id);

  @DELETE("/blogs/delete/{id}")
  Future<dynamic> deleteBlog(@Path("id") String id);

  // ==========================================
  // 16. Enquiries (Contact & Careers)
  // ==========================================
  @POST("/contacts/add")
  Future<dynamic> addContactEnquiry(@Body() ContactRequest body);

  @POST("/contacts/update/{id}")
  Future<dynamic> updateContactEnquiry(
    @Path("id") String id,
    @Body() dynamic body,
  );

  @GET("/contacts")
  Future<dynamic> getContactEnquiries();

  @DELETE("/contacts/delete/{id}")
  Future<dynamic> deleteContactEnquiry(@Path("id") String id);

  @POST("/career-enquiries/add")
  Future<dynamic> addCareerEnquiry(@Body() dynamic body);

  @POST("/career-enquiries/update/{id}")
  Future<dynamic> updateCareerEnquiry(
    @Path("id") String id,
    @Body() dynamic body,
  );

  @GET("/career-enquiries")
  Future<dynamic> getCareerEnquiries(@Query("status") String? status);

  @DELETE("/career-enquiries/delete/{id}")
  Future<dynamic> deleteCareerEnquiry(@Path("id") String id);

  // ==========================================
  // 17. User Property Reselling
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

  // ==========================================
  // 18. Income & Installments
  // ==========================================
  @GET("/income/advisor/{advisorCode}")
  Future<dynamic> getAdvisorIncome(@Path("advisorCode") String advisorCode);

  @GET("/income/analytics")
  Future<dynamic> getIncomeAnalytics();

  @GET("/installments/upcoming")
  Future<dynamic> getUpcomingInstallments(
    @Query("advisor_code") String? advisorCode,
  );
}
