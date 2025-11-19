import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shahrnet_admin/core/models/peer_survey.dart';
import 'package:shahrnet_admin/features/analytics/domain/analytics_providers.dart';
import 'package:shahrnet_admin/features/analytics/domain/peer_survey_service.dart';

/// Provider for peer survey service
final peerSurveyServiceProvider = Provider<PeerSurveyService>((ref) {
  return PeerSurveyService();
});

/// Provider for survey targets for current user
final surveyTargetsProvider = FutureProvider.autoDispose
    .family<List<SurveyTarget>, String>((ref, userId) async {
  final service = ref.watch(peerSurveyServiceProvider);

  return service.getSurveyTargets(userId: userId);
});

/// Provider for survey responses
final surveyResponsesProvider =
    FutureProvider.autoDispose<List<PeerSurveyResponse>>((ref) async {
  final service = ref.watch(peerSurveyServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return service.getSurveyResponses(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});

/// Provider for user's own survey responses
final userSurveyResponsesProvider = FutureProvider.autoDispose
    .family<List<PeerSurveyResponse>, String>((ref, userId) async {
  final service = ref.watch(peerSurveyServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return service.getSurveyResponses(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
    userId: userId,
  );
});

/// Provider for a specific survey response
final surveyResponseByIdProvider = FutureProvider.autoDispose
    .family<PeerSurveyResponse?, String>((ref, responseId) async {
  final service = ref.watch(peerSurveyServiceProvider);

  return service.getSurveyResponseById(responseId: responseId);
});

/// Provider for survey statistics
final surveyStatisticsProvider =
    FutureProvider.autoDispose<SurveyStatistics>((ref) async {
  final service = ref.watch(peerSurveyServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return service.getSurveyStatistics(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});

/// Provider for manager ratings aggregated
final managerRatingsAggregatedProvider =
    FutureProvider.autoDispose<Map<String, List<ManagerRating>>>((ref) async {
  final service = ref.watch(peerSurveyServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return service.getManagerRatingsAggregated(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});

/// Provider for colleague ratings aggregated
final colleagueRatingsAggregatedProvider =
    FutureProvider.autoDispose<Map<String, List<ColleagueRating>>>((ref) async {
  final service = ref.watch(peerSurveyServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return service.getColleagueRatingsAggregated(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});

/// Provider for user's most recent survey response
final userRecentSurveyProvider = FutureProvider.autoDispose
    .family<PeerSurveyResponse?, String>((ref, userId) async {
  final service = ref.watch(peerSurveyServiceProvider);

  return service.getUserSurveyResponse(userId: userId);
});

/// Provider to check if user has recent survey submission
final hasRecentSurveyProvider = FutureProvider.autoDispose
    .family<bool, String>((ref, userId) async {
  final service = ref.watch(peerSurveyServiceProvider);

  return service.hasRecentSurveySubmission(
    userId: userId,
    withinDays: 7,
  );
});

/// State provider for survey submission status
final surveySubmissionStatusProvider =
    StateProvider<AsyncValue<PeerSurveyResponse?>>((ref) {
  return const AsyncValue.data(null);
});
