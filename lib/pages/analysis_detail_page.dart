import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/data/mock_data.dart';
import 'package:flexly/services/analysis_service.dart';
import 'package:flexly/services/event_bus.dart';
import 'package:flexly/services/comment_service.dart';
import 'package:flexly/services/auth_service.dart';

class AnalysisDetailPage extends StatefulWidget {
  final String date;
  final double overallRating;
  final Map<String, double> bodyPartRatings;
  final String adviceTitle;
  final String adviceDescription;
  final List<String> imageUrls;
  final bool isMe;
  final String? analysisId;

  const AnalysisDetailPage({
    super.key,
    required this.date,
    required this.overallRating,
    required this.bodyPartRatings,
    this.adviceTitle = MockData.adviceTitle,
    this.adviceDescription = MockData.adviceDescription,
    this.imageUrls = const [],
    this.isMe = true,
    this.analysisId,
  });

  @override
  State<AnalysisDetailPage> createState() => _AnalysisDetailPageState();
}

class _AnalysisDetailPageState extends State<AnalysisDetailPage> {
  int _currentImageIndex = 0;
  final _commentService = CommentService();
  final _authService = AuthService();
  final TextEditingController _commentController = TextEditingController();
  List<dynamic> _comments = [];
  bool _commentsLoading = false;
  bool _isPosting = false;
  String? _currentUserId;

  Future<void> _handleDelete() async {
    if (widget.analysisId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: Text('Delete Analysis?',
            style: TextStyle(color: AppColors.white)),
        content: Text(
          'Are you sure you want to delete this analysis? This action cannot be undone.',
          style: TextStyle(color: AppColors.grayLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await AnalysisService().deleteAnalysis(widget.analysisId!);
        EventBus().fire(AnalysisDeletedEvent(widget.analysisId!));
        if (mounted) {
          Navigator.pop(context, true); // Go back with success signal
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting analysis: $e')),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadComments();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getUser();
    if (mounted && user != null) {
      setState(() {
        _currentUserId = user['_id'];
      });
    }
  }

  Future<void> _loadComments() async {
    if (widget.analysisId == null) return;
    if (mounted) setState(() => _commentsLoading = true);
    try {
      final data = await _commentService.getComments(widget.analysisId!);
      if (mounted) {
        setState(() {
          _comments = data;
          _commentsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _commentsLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load comments: $e')),
        );
      }
    }
  }

  Future<void> _submitComment() async {
    if (widget.analysisId == null || _isPosting) return;
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPosting = true);
    try {
      final comment = await _commentService.addComment(widget.analysisId!, text);
      if (mounted) {
        setState(() {
          _comments.insert(0, comment);
          _isPosting = false;
          _commentController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPosting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post comment: $e')),
        );
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await _commentService.deleteComment(commentId);
      if (mounted) {
        setState(() {
          _comments.removeWhere((c) => c['_id'] == commentId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete comment: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dynamically prepare stats
    final statsEntries = widget.bodyPartRatings.entries.toList();
    // Sort if needed, or rely on map order.
    // Split into two columns
    final mid = (statsEntries.length / 2).ceil();
    final leftStats = statsEntries.take(mid).toList();
    final rightStats = statsEntries.skip(mid).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCircleButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        if (widget.isMe && widget.analysisId != null)
                          _buildCircleButton(
                            icon: Icons.delete_outline,
                            color: Colors.red,
                            onTap: _handleDelete,
                          )
                        else
                          const SizedBox(width: 48),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          widget.date,
                          style:
                              AppTextStyles.h2.copyWith(color: AppColors.white),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.isMe
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : AppColors.grayLight.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: widget.isMe
                                    ? AppColors.primary
                                    : AppColors.grayLight,
                                width: 0.5),
                          ),
                          child: Text(
                            widget.isMe ? 'My Post' : "Other's Post",
                            style: AppTextStyles.small.copyWith(
                              color: widget.isMe
                                  ? AppColors.primary
                                  : AppColors.grayLight,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Image Carousel
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: widget.imageUrls.isEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            MockData.placeholderImage,
                            fit: BoxFit.cover,
                            opacity: const AlwaysStoppedAnimation(0.1),
                          ),
                        )
                      : Stack(
                          children: [
                            PageView.builder(
                              itemCount: widget.imageUrls.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    widget.imageUrls[index],
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                            if (widget.imageUrls.length > 1)
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    widget.imageUrls.length,
                                    (index) => Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _currentImageIndex == index
                                            ? AppColors.primary
                                            : AppColors.white
                                                .withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 24),
                // Analysis Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Analysis:',
                      style: AppTextStyles.h2,
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: widget.overallRating.toString(),
                            style: AppTextStyles.h1.copyWith(fontSize: 40),
                          ),
                          TextSpan(
                            text: ' / 10',
                            style: AppTextStyles.h3
                                .copyWith(color: AppColors.grayLight),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Stats Grid
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.grayDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: leftStats
                              .map((e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: _buildStatRow(
                                        _capitalize(e.key), e.value),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(width: 24),
                      if (rightStats.isNotEmpty) ...[
                        Container(
                          width: 1,
                          height: (rightStats.length * 40)
                              .toDouble(), // Approximate height
                          color: AppColors.gray,
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            children: rightStats
                                .map((e) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 24),
                                      child: _buildStatRow(
                                          _capitalize(e.key), e.value),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Advice Section
                Text(
                  'Advice:',
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.grayDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.adviceTitle,
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.adviceDescription,
                        style: AppTextStyles.body1
                            .copyWith(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildCommentsSection(),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(
      {required IconData icon, required VoidCallback onTap, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.grayDark,
          border: Border.all(color: AppColors.gray, width: 1),
        ),
        child: Icon(
          icon,
          color: color ?? AppColors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, double value) {
    final isVisible = value > 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: AppTextStyles.body2.copyWith(color: AppColors.white),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: isVisible ? value.toString() : '-',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isVisible)
                TextSpan(
                  text: '/10',
                  style: AppTextStyles.caption1
                      .copyWith(color: AppColors.grayLight),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Comments:', style: AppTextStyles.h2),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.grayDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: AppTextStyles.body2.copyWith(color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: TextStyle(color: AppColors.grayLight),
                    border: InputBorder.none,
                  ),
                  minLines: 1,
                  maxLines: 4,
                ),
              ),
              IconButton(
                icon: _isPosting
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Icon(Icons.send, color: AppColors.primary),
                onPressed: _isPosting ? null : _submitComment,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_commentsLoading)
          Center(
            child:
                CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
          )
        else if (_comments.isEmpty)
          Text(
            'No comments yet. Be the first!',
            style: AppTextStyles.body2.copyWith(color: AppColors.grayLight),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            separatorBuilder: (_, __) => Divider(color: AppColors.gray),
            itemBuilder: (context, index) {
              final comment = _comments[index];
              final user = comment['user'] ?? {};
              final createdAt = comment['createdAt'] != null
                  ? DateTime.parse(comment['createdAt'])
                  : DateTime.now();
              final canDelete =
                  _currentUserId != null && user['_id'] == _currentUserId;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.gray,
                    backgroundImage: user['profilePicture'] != null &&
                            (user['profilePicture'] as String).isNotEmpty
                        ? NetworkImage(user['profilePicture'])
                        : null,
                    child: user['profilePicture'] == null ||
                            (user['profilePicture'] as String).isEmpty
                        ? Icon(Icons.person,
                          color: AppColors.grayLight, size: 18)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user['username'] != null
                                  ? '@${user['username']}'
                                  : (user['name'] ?? 'User'),
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _timeAgo(createdAt),
                              style: AppTextStyles.caption2
                                  .copyWith(color: AppColors.grayLight),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          comment['text'] ?? '',
                          style:
                              AppTextStyles.body2.copyWith(color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                  if (canDelete)
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          size: 18, color: AppColors.grayLight),
                      onPressed: () => _deleteComment(comment['_id']),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
