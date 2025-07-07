# Frontend-Backend Integration Plan

## WasteSorter App

### 📋 **Integration Checklist**

#### **Phase 1: API Contract Definition** ✅

- [x] Data models created (`ClassificationResult`, `UserProfile`, etc.)
- [x] Service interfaces defined (`ClassificationService`, `UserService`, etc.)
- [x] API documentation created (`api_documentation.dart`)
- [x] Mock services implemented for parallel development

#### **Phase 2: Backend API Requirements** 🔄

- [ ] Backend team reviews API documentation
- [ ] Endpoint URLs and base URL confirmed
- [ ] Authentication strategy finalized (JWT tokens)
- [ ] Error handling conventions agreed upon
- [ ] Rate limiting specifications confirmed

#### **Phase 3: Real Service Implementation** ⏳

- [ ] HTTP client service created
- [ ] Real classification service implemented
- [ ] User authentication service implemented
- [ ] Progress tracking service implemented
- [ ] Leaderboard service implemented

#### **Phase 4: Testing & Integration** ⏳

- [ ] API integration testing
- [ ] Error handling validation
- [ ] Performance optimization
- [ ] Offline functionality (if needed)

---

### 🤝 **Backend Team Communication**

#### **Immediate Questions for Backend Team:**

1. **API Base URL**: What will be the base URL for the API?

   - Development: `https://api-dev.wastesorter.com`
   - Production: `https://api.wastesorter.com`

2. **Image Classification**:

   - What's the maximum image file size you can handle?
   - Do you need specific image dimensions/format preprocessing?
   - What's the expected response time for classification?

3. **Authentication**:

   - Are you using Firebase Auth or custom JWT?
   - What's the token expiration time?
   - Do you need refresh token functionality?

4. **Database Schema**:

   - What's your user ID format? (UUID, incremental, etc.)
   - How are you handling user locations for local leaderboards?
   - What's your caching strategy for leaderboards?

5. **Rate Limiting**:
   - What are the rate limits per endpoint?
   - How should the frontend handle rate limit errors?

#### **Files to Share with Backend Team:**

- `lib/services/api_documentation.dart` - Complete API specification
- `lib/models/classification_result.dart` - Data model contracts
- `lib/models/user_models.dart` - User data structures

---

### 🔧 **Frontend Architecture Ready for Integration**

#### **Service Layer Pattern**:

```dart
// Current mock service can be easily swapped
final classificationServiceProvider = Provider<ClassificationService>((ref) {
  // DEVELOPMENT
  return MockClassificationService();

  // PRODUCTION (when backend ready)
  // return HttpClassificationService(
  //   baseUrl: AppConfig.apiBaseUrl,
  //   httpClient: ref.read(httpClientProvider),
  // );
});
```

#### **State Management Ready**:

- Riverpod providers configured for all services
- State notifiers handle user authentication
- Future providers manage async data loading
- Error handling infrastructure in place

#### **Error Handling Strategy**:

```dart
try {
  final result = await classificationService.classifyImage(imagePath);
  // Handle success
} on ClassificationException catch (e) {
  // Handle classification-specific errors
} catch (e) {
  // Handle general errors
}
```

---

### 📝 **Next Steps for You (Frontend)**

#### **Week 1:**

1. **Create HTTP Client Service**:

   ```dart
   // lib/services/http_client.dart
   class ApiClient {
     static const String baseUrl = 'https://api.wastesorter.com';

     Future<http.Response> post(String endpoint, Map<String, dynamic> data);
     Future<http.Response> get(String endpoint);
     // etc.
   }
   ```

2. **Implement Real Classification Service**:
   ```dart
   // lib/services/http_classification_service.dart
   class HttpClassificationService implements ClassificationService {
     @override
     Future<ClassificationResult> classifyImage(String imagePath) async {
       // Actual API call implementation
     }
   }
   ```

#### **Week 2:**

1. **Create Configuration Management**:

   ```dart
   // lib/core/config/app_config.dart
   class AppConfig {
     static const String apiBaseUrl = String.fromEnvironment(
       'API_BASE_URL',
       defaultValue: 'https://api-dev.wastesorter.com',
     );
   }
   ```

2. **Add Error Handling UI**:
   - Network error dialogs
   - Retry mechanisms
   - Offline indicators

#### **Week 3:**

1. **Integration Testing**:
   - Test all API endpoints
   - Validate error scenarios
   - Performance testing

---

### 🎯 **Success Metrics**

- [ ] All API endpoints working correctly
- [ ] User authentication flow complete
- [ ] Real image classification functional
- [ ] Leaderboards displaying live data
- [ ] Error handling gracefully manages failures
- [ ] App works offline with cached data (optional)

---

### 📞 **Communication Protocol**

#### **Daily Standup Questions**:

1. What API endpoints are ready for testing?
2. Any changes to the data models/API contracts?
3. What integration blockers exist?

#### **Weekly Integration Review**:

1. Demo current working endpoints
2. Review any API changes needed
3. Plan next week's integration priorities

This plan ensures smooth collaboration and minimizes integration issues! 🚀
