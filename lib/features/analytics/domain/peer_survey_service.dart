import 'package:shahrnet_admin/core/models/peer_survey.dart';
import '../data/mock_peer_survey.dart';

/// Service for peer survey data
class PeerSurveyService {
  // Simulated cache
  List<PeerSurveyResponse>? _cachedResponses;
  List<SurveyTarget>? _cachedTargets;
  DateTime? _cacheTime;

  /// Get survey targets for a user
  Future<List<SurveyTarget>> getSurveyTargets({
    required String userId,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    // Check cache
    if (_cachedTargets != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!).inMinutes < 10) {
      return _cachedTargets!;
    }

    // Generate targets
    _cachedTargets = MockPeerSurvey.generateSurveyTargets(
      currentUserId: userId,
      colleagueCount: 10,
    );
    _cacheTime = DateTime.now();

    return _cachedTargets!;
  }

  /// Submit a survey response
  Future<PeerSurveyResponse> submitSurvey({
    required SurveySubmissionRequest request,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Create response
    final response = PeerSurveyResponse(
      id: 'response_${DateTime.now().millisecondsSinceEpoch}',
      respondentId: request.respondentId,
      respondentName: 'کاربر فعلی', // Would come from auth in real app
      submittedAt: DateTime.now(),
      managerRating: request.managerRating,
      colleagueRatings: request.colleagueRatings,
      selfMoodReport: request.selfMoodReport,
    );

    // Update cache
    _cachedResponses ??= [];
    _cachedResponses!.add(response);

    // Invalidate targets cache to reflect new ratings
    _cachedTargets = null;

    return response;
  }

  /// Update an existing survey response
  Future<PeerSurveyResponse> updateSurvey({
    required String responseId,
    required SurveySubmissionRequest request,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Find and update response
    if (_cachedResponses != null) {
      final index = _cachedResponses!.indexWhere((r) => r.id == responseId);
      if (index != -1) {
        final oldResponse = _cachedResponses![index];
        final updatedResponse = PeerSurveyResponse(
          id: responseId,
          respondentId: request.respondentId,
          respondentName: oldResponse.respondentName,
          submittedAt: oldResponse.submittedAt,
          lastUpdatedAt: DateTime.now(),
          managerRating: request.managerRating,
          colleagueRatings: request.colleagueRatings,
          selfMoodReport: request.selfMoodReport,
        );

        _cachedResponses![index] = updatedResponse;
        return updatedResponse;
      }
    }

    // If not found, submit as new
    return submitSurvey(request: request);
  }

  /// Get survey responses for a date range
  Future<List<PeerSurveyResponse>> getSurveyResponses({
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Generate or use cached responses
    if (_cachedResponses == null ||
        _cacheTime == null ||
        DateTime.now().difference(_cacheTime!).inMinutes > 5) {
      _cachedResponses = MockPeerSurvey.generateSurveyResponses(
        count: 50,
        startDate: startDate,
        endDate: endDate,
      );
      _cacheTime = DateTime.now();
    }

    var responses = _cachedResponses!;

    // Filter by date range
    responses = responses
        .where((r) =>
            r.submittedAt.isAfter(startDate) &&
            r.submittedAt.isBefore(endDate))
        .toList();

    // Filter by user if specified
    if (userId != null) {
      responses = responses.where((r) => r.respondentId == userId).toList();
    }

    return responses;
  }

  /// Get survey response by ID
  Future<PeerSurveyResponse?> getSurveyResponseById({
    required String responseId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (_cachedResponses == null) return null;

    return _cachedResponses!
        .where((r) => r.id == responseId)
        .firstOrNull;
  }

  /// Get survey statistics
  Future<SurveyStatistics> getSurveyStatistics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final responses = await getSurveyResponses(
      startDate: startDate,
      endDate: endDate,
    );

    return MockPeerSurvey.generateSurveyStatistics(
      responses: responses,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get manager ratings aggregated
  Future<Map<String, List<ManagerRating>>> getManagerRatingsAggregated({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final responses = await getSurveyResponses(
      startDate: startDate,
      endDate: endDate,
    );

    final ratingsMap = <String, List<ManagerRating>>{};

    for (final response in responses) {
      if (response.managerRating != null) {
        final managerId = response.managerRating!.managerId;
        ratingsMap[managerId] ??= [];
        ratingsMap[managerId]!.add(response.managerRating!);
      }
    }

    return ratingsMap;
  }

  /// Get colleague ratings aggregated
  Future<Map<String, List<ColleagueRating>>> getColleagueRatingsAggregated({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final responses = await getSurveyResponses(
      startDate: startDate,
      endDate: endDate,
    );

    final ratingsMap = <String, List<ColleagueRating>>{};

    for (final response in responses) {
      for (final rating in response.colleagueRatings) {
        final colleagueId = rating.colleagueId;
        ratingsMap[colleagueId] ??= [];
        ratingsMap[colleagueId]!.add(rating);
      }
    }

    return ratingsMap;
  }

  /// Get user's own survey response
  Future<PeerSurveyResponse?> getUserSurveyResponse({
    required String userId,
  }) async {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30));

    final responses = await getSurveyResponses(
      startDate: startDate,
      endDate: now,
      userId: userId,
    );

    return responses.isNotEmpty ? responses.last : null;
  }

  /// Check if user has submitted survey recently (within days)
  Future<bool> hasRecentSurveySubmission({
    required String userId,
    int withinDays = 7,
  }) async {
    final response = await getUserSurveyResponse(userId: userId);

    if (response == null) return false;

    final daysSinceSubmission =
        DateTime.now().difference(response.submittedAt).inDays;

    return daysSinceSubmission <= withinDays;
  }

  /// Clear cache
  void clearCache() {
    _cachedResponses = null;
    _cachedTargets = null;
    _cacheTime = null;
  }
}
