import 'package:shahrnet_admin/core/models/engagement_analytics.dart';
import 'package:shahrnet_admin/core/models/sentiment_analytics.dart';
import '../data/mock_engagement_analytics.dart';

/// Service for engagement analytics data
class EngagementAnalyticsService {
  // Simulated cache
  EngagementAnalytics? _cachedAnalytics;
  DateTime? _cacheTime;

  /// Get engagement analytics for a date range
  Future<EngagementAnalytics> getEngagementAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Check if cached data is still valid (5 minutes)
    if (_cachedAnalytics != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!).inMinutes < 5) {
      return _cachedAnalytics!;
    }

    // Generate new data
    _cachedAnalytics = MockEngagementAnalytics.generateEngagementAnalytics(
      startDate: startDate,
      endDate: endDate,
    );
    _cacheTime = DateTime.now();

    return _cachedAnalytics!;
  }

  /// Get employee risk profiles
  Future<List<EmployeeRiskProfile>> getEmployeeRiskProfiles({
    required DateTime startDate,
    required DateTime endDate,
    RiskLevel? filterByRisk,
    String? searchQuery,
  }) async {
    final analytics = await getEngagementAnalytics(
      startDate: startDate,
      endDate: endDate,
    );

    var profiles = analytics.employeeRiskProfiles;

    // Filter by risk level
    if (filterByRisk != null) {
      profiles = profiles.where((p) => p.riskLevel == filterByRisk).toList();
    }

    // Search by name
    if (searchQuery != null && searchQuery.isNotEmpty) {
      profiles = profiles
          .where((p) =>
              p.userName.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return profiles;
  }

  /// Get employee by ID
  Future<EmployeeRiskProfile?> getEmployeeById({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final analytics = await getEngagementAnalytics(
      startDate: startDate,
      endDate: endDate,
    );

    return analytics.employeeRiskProfiles
        .where((p) => p.userId == userId)
        .firstOrNull;
  }

  /// Get company engagement summary
  Future<CompanyEngagementSummary> getCompanyEngagementSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final analytics = await getEngagementAnalytics(
      startDate: startDate,
      endDate: endDate,
    );

    return analytics.companyEngagementSummary;
  }

  /// Get manager support profiles
  Future<List<ManagerSupportProfile>> getManagerSupportProfiles({
    required DateTime startDate,
    required DateTime endDate,
    String? searchQuery,
  }) async {
    final analytics = await getEngagementAnalytics(
      startDate: startDate,
      endDate: endDate,
    );

    var profiles = analytics.managerSupportProfiles;

    // Search by name
    if (searchQuery != null && searchQuery.isNotEmpty) {
      profiles = profiles
          .where((p) =>
              p.managerName.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    // Sort by supportiveness score (highest first)
    profiles.sort((a, b) => b.supportivenessScore.compareTo(a.supportivenessScore));

    return profiles;
  }

  /// Get manager by ID
  Future<ManagerSupportProfile?> getManagerById({
    required String managerId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final analytics = await getEngagementAnalytics(
      startDate: startDate,
      endDate: endDate,
    );

    return analytics.managerSupportProfiles
        .where((p) => p.managerId == managerId)
        .firstOrNull;
  }

  /// Get smart insights
  Future<List<SmartInsight>> getInsights({
    required DateTime startDate,
    required DateTime endDate,
    InsightType? filterByType,
  }) async {
    final analytics = await getEngagementAnalytics(
      startDate: startDate,
      endDate: endDate,
    );

    var insights = analytics.insights;

    // Filter by type
    if (filterByType != null) {
      insights = insights.where((i) => i.type == filterByType).toList();
    }

    return insights;
  }

  /// Get at-risk employees
  Future<List<EmployeeRiskProfile>> getAtRiskEmployees({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 20,
  }) async {
    final analytics = await getEngagementAnalytics(
      startDate: startDate,
      endDate: endDate,
    );

    return analytics.companyEngagementSummary.atRiskEmployees.take(limit).toList();
  }

  /// Get top engaged employees
  Future<List<EmployeeRiskProfile>> getTopEngagedEmployees({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  }) async {
    final analytics = await getEngagementAnalytics(
      startDate: startDate,
      endDate: endDate,
    );

    return analytics.companyEngagementSummary.topEngagedEmployees
        .take(limit)
        .toList();
  }

  /// Clear cache
  void clearCache() {
    _cachedAnalytics = null;
    _cacheTime = null;
  }
}
