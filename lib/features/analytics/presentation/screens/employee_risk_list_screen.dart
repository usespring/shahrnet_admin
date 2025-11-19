import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shahrnet_admin/core/models/engagement_analytics.dart';
import '../../domain/engagement_analytics_providers.dart';
import 'employee_detail_screen.dart';

/// Screen showing list of employees with their risk profiles
class EmployeeRiskListScreen extends ConsumerStatefulWidget {
  const EmployeeRiskListScreen({super.key});

  @override
  ConsumerState<EmployeeRiskListScreen> createState() =>
      _EmployeeRiskListScreenState();
}

class _EmployeeRiskListScreenState
    extends ConsumerState<EmployeeRiskListScreen> {
  RiskLevel? _selectedRiskFilter;
  String _searchQuery = '';
  bool _sortByRisk = true;

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeeRiskProfilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لیست کارمندان'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(employeeRiskProfilesProvider);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'جستجوی کارمند...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              // Filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text('همه'),
                              selected: _selectedRiskFilter == null,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedRiskFilter = null;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('خطر بالا'),
                              selected: _selectedRiskFilter == RiskLevel.high,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedRiskFilter =
                                      selected ? RiskLevel.high : null;
                                });
                              },
                              backgroundColor: Colors.red[50],
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('خطر متوسط'),
                              selected: _selectedRiskFilter == RiskLevel.medium,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedRiskFilter =
                                      selected ? RiskLevel.medium : null;
                                });
                              },
                              backgroundColor: Colors.orange[50],
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('خطر کم'),
                              selected: _selectedRiskFilter == RiskLevel.low,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedRiskFilter =
                                      selected ? RiskLevel.low : null;
                                });
                              },
                              backgroundColor: Colors.green[50],
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _sortByRisk ? Icons.arrow_downward : Icons.arrow_upward,
                      ),
                      onPressed: () {
                        setState(() {
                          _sortByRisk = !_sortByRisk;
                        });
                      },
                      tooltip: 'مرتب‌سازی',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: employeesAsync.when(
        data: (employees) {
          // Filter employees
          var filtered = employees;

          if (_selectedRiskFilter != null) {
            filtered = filtered
                .where((e) => e.riskLevel == _selectedRiskFilter)
                .toList();
          }

          if (_searchQuery.isNotEmpty) {
            filtered = filtered
                .where((e) => e.userName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
                .toList();
          }

          // Sort employees
          filtered.sort((a, b) {
            if (_sortByRisk) {
              return b.dropOffRiskScore.compareTo(a.dropOffRiskScore);
            } else {
              return a.dropOffRiskScore.compareTo(b.dropOffRiskScore);
            }
          });

          if (filtered.isEmpty) {
            return const Center(
              child: Text('هیچ کارمندی یافت نشد'),
            );
          }

          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final employee = filtered[index];
              return _buildEmployeeCard(context, employee);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('خطا: $error')),
      ),
    );
  }

  Widget _buildEmployeeCard(BuildContext context, EmployeeRiskProfile employee) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmployeeDetailScreen(
                employeeId: employee.userId,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getRiskColor(employee.dropOffRiskScore),
                    child: Text(
                      employee.userName.substring(0, 1),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          employee.managerName ?? 'بدون مدیر',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getRiskColor(employee.dropOffRiskScore)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          employee.riskLevel.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getRiskColor(employee.dropOffRiskScore),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                      'خطر ترک',
                      employee.dropOffRiskScore.toStringAsFixed(0),
                      _getRiskColor(employee.dropOffRiskScore),
                    ),
                  ),
                  Expanded(
                    child: _buildMetric(
                      'مشارکت',
                      employee.engagementScore.toStringAsFixed(0),
                      _getEngagementColor(employee.engagementScore),
                    ),
                  ),
                  Expanded(
                    child: _buildMetric(
                      'غیرفعال',
                      '${employee.daysInactive} روز',
                      Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Warning indicators
              if (employee.activityDeclineSignals.hasSignificantDecline ||
                  employee.behavioralSignals.hasIncreasedNegativity)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (employee.activityDeclineSignals.hasSignificantDecline)
                      _buildWarningChip('کاهش فعالیت', Icons.trending_down),
                    if (employee.behavioralSignals.hasIncreasedNegativity)
                      _buildWarningChip('احساس منفی', Icons.sentiment_dissatisfied),
                    if (employee.behavioralSignals.consecutiveInactiveWeeks > 0)
                      _buildWarningChip(
                        '${employee.behavioralSignals.consecutiveInactiveWeeks} هفته غیرفعال',
                        Icons.calendar_today,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildWarningChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.orange[700]),
      label: Text(label),
      backgroundColor: Colors.orange[50],
      labelStyle: const TextStyle(fontSize: 11),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Color _getRiskColor(double score) {
    if (score < 40) return Colors.green;
    if (score < 70) return Colors.orange;
    return Colors.red;
  }

  Color _getEngagementColor(double score) {
    if (score >= 70) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}
