import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shahrnet_admin/core/models/peer_survey.dart';
import 'package:shahrnet_admin/core/models/sentiment_analytics.dart';
import '../../domain/peer_survey_providers.dart';

/// Screen for employees to submit peer surveys
class PeerSurveyScreen extends ConsumerStatefulWidget {
  final String currentUserId;

  const PeerSurveyScreen({
    super.key,
    required this.currentUserId,
  });

  @override
  ConsumerState<PeerSurveyScreen> createState() => _PeerSurveyScreenState();
}

class _PeerSurveyScreenState extends ConsumerState<PeerSurveyScreen> {
  // Manager rating
  ManagerRating? _managerRating;
  double _managerSupportiveness = 3.0;
  double _managerCommunication = 3.0;
  double _managerFairness = 3.0;
  double _managerLeadership = 3.0;
  final TextEditingController _managerCommentController =
      TextEditingController();

  // Colleague ratings
  final Map<String, ColleagueRating> _colleagueRatings = {};

  // Self mood
  MoodLevel _selectedMood = MoodLevel.neutral;
  final TextEditingController _moodCommentController = TextEditingController();

  @override
  void dispose() {
    _managerCommentController.dispose();
    _moodCommentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetsAsync = ref.watch(surveyTargetsProvider(widget.currentUserId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('نظرسنجی همکاران'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(surveyTargetsProvider(widget.currentUserId));
            },
          ),
        ],
      ),
      body: targetsAsync.when(
        data: (targets) {
          final manager = targets
              .where((t) => t.targetType == SurveyTargetType.manager)
              .firstOrNull;
          final colleagues = targets
              .where((t) => t.targetType == SurveyTargetType.colleague)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Introduction
                Card(
                  color: Colors.blue[50],
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'لطفاً به سوالات زیر پاسخ دهید. پاسخ‌های شما محرمانه است و به بهبود محیط کاری کمک می‌کند.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Manager rating
                if (manager != null) ...[
                  _buildSectionHeader('ارزیابی مدیر'),
                  const SizedBox(height: 12),
                  _buildManagerRatingSection(manager),
                  const SizedBox(height: 24),
                ],

                // Colleague ratings
                if (colleagues.isNotEmpty) ...[
                  _buildSectionHeader('ارزیابی همکاران'),
                  const SizedBox(height: 12),
                  ...colleagues.map((colleague) =>
                      _buildColleagueRatingSection(colleague)),
                  const SizedBox(height: 24),
                ],

                // Self mood report
                _buildSectionHeader('وضعیت احساسی شما'),
                const SizedBox(height: 12),
                _buildMoodSection(),
                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitSurvey,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text(
                      'ثبت نظرسنجی',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('خطا: $error')),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildManagerRatingSection(SurveyTarget manager) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              manager.userName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildRatingSlider(
              'پشتیبانی و حمایت',
              _managerSupportiveness,
              (value) => setState(() => _managerSupportiveness = value),
            ),
            _buildRatingSlider(
              'کیفیت ارتباطات',
              _managerCommunication,
              (value) => setState(() => _managerCommunication = value),
            ),
            _buildRatingSlider(
              'انصاف و بی‌طرفی',
              _managerFairness,
              (value) => setState(() => _managerFairness = value),
            ),
            _buildRatingSlider(
              'رهبری',
              _managerLeadership,
              (value) => setState(() => _managerLeadership = value),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _managerCommentController,
              decoration: const InputDecoration(
                labelText: 'نظر شما (اختیاری)',
                hintText: 'نظر خود را در مورد مدیرتان بنویسید...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColleagueRatingSection(SurveyTarget colleague) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(colleague.userName),
          subtitle: colleague.hasBeenRated
              ? const Text(
                  'ارزیابی شده ✓',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                )
              : null,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildColleagueRating(colleague),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColleagueRating(SurveyTarget colleague) {
    final existingRating = _colleagueRatings[colleague.userId];
    final collaboration = existingRating?.collaborationRating ?? 3.0;
    final helpfulness = existingRating?.helpfulnessRating ?? 3.0;
    final teamSpirit = existingRating?.teamSpiritRating ?? 3.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRatingSlider(
          'همکاری',
          collaboration,
          (value) {
            _updateColleagueRating(
              colleague,
              collaboration: value,
              helpfulness: helpfulness,
              teamSpirit: teamSpirit,
            );
          },
        ),
        _buildRatingSlider(
          'کمک‌رسانی',
          helpfulness,
          (value) {
            _updateColleagueRating(
              colleague,
              collaboration: collaboration,
              helpfulness: value,
              teamSpirit: teamSpirit,
            );
          },
        ),
        _buildRatingSlider(
          'روحیه تیمی',
          teamSpirit,
          (value) {
            _updateColleagueRating(
              colleague,
              collaboration: collaboration,
              helpfulness: helpfulness,
              teamSpirit: value,
            );
          },
        ),
      ],
    );
  }

  void _updateColleagueRating(
    SurveyTarget colleague, {
    required double collaboration,
    required double helpfulness,
    required double teamSpirit,
  }) {
    setState(() {
      _colleagueRatings[colleague.userId] = ColleagueRating(
        colleagueId: colleague.userId,
        colleagueName: colleague.userName,
        collaborationRating: collaboration,
        helpfulnessRating: helpfulness,
        teamSpiritRating: teamSpirit,
      );
    });
  }

  Widget _buildRatingSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < value ? Icons.star : Icons.star_border,
                  size: 20,
                  color: Colors.amber,
                );
              }),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 1,
          max: 5,
          divisions: 4,
          label: value.toStringAsFixed(0),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildMoodSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'امروز چطور احساس می‌کنید؟',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: MoodLevel.values.map((mood) {
                final isSelected = _selectedMood == mood;
                return InkWell(
                  onTap: () => setState(() => _selectedMood = mood),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[50] : null,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          mood.emoji,
                          style: TextStyle(
                            fontSize: isSelected ? 40 : 32,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mood.displayName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _moodCommentController,
              decoration: const InputDecoration(
                labelText: 'توضیحات (اختیاری)',
                hintText: 'اگر می‌خواهید، در مورد احساستان بنویسید...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitSurvey() async {
    final targetsAsync = ref.read(surveyTargetsProvider(widget.currentUserId));

    await targetsAsync.when(
      data: (targets) async {
        final manager = targets
            .where((t) => t.targetType == SurveyTargetType.manager)
            .firstOrNull;

        // Build submission request
        final request = SurveySubmissionRequest(
          respondentId: widget.currentUserId,
          managerRating: manager != null
              ? ManagerRating(
                  managerId: manager.userId,
                  managerName: manager.userName,
                  supportivenessRating: _managerSupportiveness,
                  communicationRating: _managerCommunication,
                  fairnessRating: _managerFairness,
                  leadershipRating: _managerLeadership,
                  comment: _managerCommentController.text.isNotEmpty
                      ? _managerCommentController.text
                      : null,
                )
              : null,
          colleagueRatings: _colleagueRatings.values.toList(),
          selfMoodReport: SelfMoodReport(
            mood: _selectedMood,
            comment: _moodCommentController.text.isNotEmpty
                ? _moodCommentController.text
                : null,
            reportedAt: DateTime.now(),
          ),
        );

        // Submit survey
        try {
          final service = ref.read(peerSurveyServiceProvider);
          await service.submitSurvey(request: request);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('نظرسنجی با موفقیت ثبت شد'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطا در ثبت نظرسنجی: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      loading: () {},
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }
}
