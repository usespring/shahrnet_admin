import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shahrnet_admin/core/models/engagement_analytics.dart';
import 'package:shahrnet_admin/core/models/sentiment_analytics.dart';
import 'package:shahrnet_admin/features/analytics/domain/analytics_providers.dart';
import 'package:shahrnet_admin/features/analytics/domain/engagement_analytics_service.dart';

/// Provider for engagement analytics service
final engagementAnalyticsServiceProvider = Provider<EngagementAnalyticsService>((ref) {
  return EngagementAnalyticsService();
});

/// Provider for engagement analytics data
final engagementAnalyticsProvider =
    FutureProvider.autoDispose<EngagementAnalytics>((ref) async {
  final service = ref.watch(engagementAnalyticsServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return service.getEngagementAnalytics(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});

/// Provider for employee risk profiles
final employeeRiskProfilesProvider =
    FutureProvider.autoDispose<List<EmployeeRiskProfile>>((ref) async {
  final service = ref.watch(engagementAnalyticsServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return service.getEmployeeRiskProfiles(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});

/// Provider for filtered employee risk profiles
final filteredEmployeeRiskProfilesProvider = FutureProvider.autoDispose
    .family<List<EmployeeRiskProfile>, RiskLevel?>((ref, riskLevel) async {
  final service = ref.watch(engagementAnalyticsServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return service.getEmployeeRiskProfiles(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
    filterByRisk: riskLevel,
  );
});

/// Provider for a specific employee
final employeeByIdProvider = FutureProvider.autoDispose
    .family<EmployeeRiskProfile?, String>((ref, userId) async {
  final service = ref.watch(engagementAnalyticsServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return service.getEmployeeById(
    userId: userId,
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});

/// Provider for company engagement summary
final companyEngagementSummaryProvider =
    FutureProvider.autoDispose<CompanyEngagementSummary>((ref) async {
  final service = ref.watch(engagementAnalyticsServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return service.getCompanyEngagementSummary(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});

/// Provider for manager support profiles
final managerSupportProfilesProvider =
    FutureProvider.autoDispose<List<ManagerSupportProfile>>((ref) async {
  final service = ref.watch(engagementAnalyticsServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return service.getManagerSupportProfiles(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});

/// Provider for a specific manager
final managerByIdProvider = FutureProvider.autoDispose
    .family<ManagerSupportProfile?, String>((ref, managerId) async {
  final service = ref.watch(engagementAnalyticsServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return service.getManagerById(
    managerId: managerId,
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});

/// Provider for engagement insights
final engagementInsightsProvider =
    FutureProvider.autoDispose<List<SmartInsight>>((ref) async {
  final service = ref.watch(engagementAnalyticsServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return service.getInsights(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});

/// Provider for at-risk employees
final atRiskEmployeesProvider =
    FutureProvider.autoDispose<List<EmployeeRiskProfile>>((ref) async {
  final service = ref.watch(engagementAnalyticsServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return service.getAtRiskEmployees(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
    limit: 20,
  );
});

/// Provider for top engaged employees
final topEngagedEmployeesProvider =
    FutureProvider.autoDispose<List<EmployeeRiskProfile>>((ref) async {
  final service = ref.watch(engagementAnalyticsServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return service.getTopEngagedEmployees(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
    limit: 10,
  );
});
