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
  Map<String, List<dynamic>> _repliesByParent = {};
  final Map<String, Map<String, dynamic>> _commentById = {};
  Map<String, bool> _repliesExpanded = {};
  bool _commentsLoading = false;
  bool _isPosting = false;
  String? _currentUserId;
  String? _replyToCommentId;
  String? _replyToUsername;

  Future<void> _handleDelete() async {
    if (widget.analysisId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title:
            Text('Delete Analysis?', style: TextStyle(color: AppColors.white)),
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
          Navigator.pop(context, true);
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
          _setThreadedComments(data);
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
      final comment = await _commentService.addComment(
        widget.analysisId!,
        text,
        parentCommentId: _replyToCommentId,
      );

      if (_replyToCommentId != null && (comment['parentComment'] == null)) {
        comment['parentComment'] = {'_id': _replyToCommentId};
      }
      if (mounted) {
        setState(() {
          _insertComment(comment);
          _isPosting = false;
          _commentController.clear();
          _replyToCommentId = null;
          _replyToUsername = null;
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

  void _setThreadedComments(List<dynamic> flat) {
    final previousExpanded = _repliesExpanded;
    _repliesByParent = {};
    _comments = [];
    _commentById.clear();
    for (final c in flat) {
      final parent = c['parentComment'];
      final id = c['_id']?.toString();
      if (id != null) {
        _commentById[id] = c as Map<String, dynamic>;
      }
      if (parent == null) {
        _comments.add(c);
      } else {
        final parentId = parent is Map ? parent['_id'] : parent.toString();
        _repliesByParent.putIfAbsent(parentId, () => []).add(c);
      }
    }
    _repliesExpanded = {};
    _repliesByParent.forEach((key, value) {
      _repliesExpanded[key] = previousExpanded[key] ?? false;
    });
  }

  void _insertComment(Map<String, dynamic> comment) {
    final parent = comment['parentComment'];
    final id = comment['_id']?.toString();
    if (id != null) {
      _commentById[id] = comment;
    }
    if (parent == null) {
      _comments.insert(0, comment);
      return;
    }
    final parentId = parent is Map ? parent['_id'] : parent.toString();
    _repliesByParent.putIfAbsent(parentId, () => []).insert(0, comment);
    _repliesExpanded[parentId] = true;
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await _commentService.deleteComment(commentId);
      if (mounted) {
        setState(() {
          _comments.removeWhere((c) => c['_id'] == commentId);
          _repliesByParent.remove(commentId);
          _repliesByParent.forEach((key, list) {
            list.removeWhere((c) => c['_id'] == commentId);
          });
          _repliesExpanded.remove(commentId);
          _commentById.remove(commentId);
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

    final statsEntries = widget.bodyPartRatings.entries.toList();


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
                              .toDouble(),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_replyToCommentId != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.gray.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Replying to ${_replyToUsername ?? 'comment'}',
                        style: AppTextStyles.caption1
                            .copyWith(color: AppColors.white),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _replyToCommentId = null;
                            _replyToUsername = null;
                          });
                        },
                        child: Icon(Icons.close,
                            size: 16, color: AppColors.grayLight),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style:
                          AppTextStyles.body2.copyWith(color: AppColors.white),
                      decoration: InputDecoration(
                        hintText: _replyToCommentId != null
                            ? 'Write a reply...'
                            : 'Add a comment...',
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
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_commentsLoading)
          Center(
            child: CircularProgressIndicator(
                color: AppColors.white, strokeWidth: 2),
          )
        else if (_comments.isEmpty)
          Text(
            'No comments yet. Be the first!',
            style: AppTextStyles.body2.copyWith(color: AppColors.grayLight),
          )
        else
          _buildThreadedComments(),
      ],
    );
  }

  Widget _buildThreadedComments() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _comments.length,
      separatorBuilder: (_, __) => Divider(color: AppColors.gray),
      itemBuilder: (context, index) {
        final comment = _comments[index];
        return _buildCommentTile(comment, isReply: false, depth: 0);
      },
    );
  }

  Widget _buildCommentTile(Map<String, dynamic> comment,
      {required bool isReply, required int depth}) {
    final user = comment['user'] ?? {};
    final createdAt = comment['createdAt'] != null
        ? DateTime.parse(comment['createdAt'])
        : DateTime.now();
    final canDelete = _currentUserId != null && user['_id'] == _currentUserId;
    final commentId = comment['_id']?.toString() ?? '';
    final replies = _repliesByParent[commentId] ?? [];
    final replyCount = replies.length;
    final expanded = _repliesExpanded[commentId] ?? false;

    final indent = depth == 1 ? 28.0 : 0.0;
    final parent = comment['parentComment'];
    String? parentUserLabel;
    if (parent != null) {
      final parentId = parent is Map ? parent['_id'] : parent.toString();
      final parentComment = _commentById[parentId];
      if (parentComment != null) {
        final pu = parentComment['user'] ?? {};
        parentUserLabel = pu['username'] != null
            ? '@${pu['username']}'
            : (pu['name'] ?? 'user');
      }
    }

    return Container(
      margin: EdgeInsets.only(left: indent, top: isReply ? 8 : 0),
      padding: const EdgeInsets.only(
        left: 0,
        right: 4,
        top: 6,
        bottom: 6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: isReply ? 16 : 18,
                backgroundColor: AppColors.grayLight,
                backgroundImage: user['profilePicture'] != null &&
                        (user['profilePicture'] as String).isNotEmpty
                    ? NetworkImage(user['profilePicture'])
                    : null,
                child: user['profilePicture'] == null ||
                        (user['profilePicture'] as String).isEmpty
                    ? Icon(Icons.person,
                        color: Colors.white, size: isReply ? 16 : 18)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isReply && parentUserLabel != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'Replying to $parentUserLabel',
                          style: AppTextStyles.caption1
                              .copyWith(color: AppColors.grayLight),
                        ),
                      ),
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _replyToCommentId = commentId;
                              _replyToUsername =
                                  user['username'] ?? user['name'];
                            });
                          },
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Text('Reply',
                              style: AppTextStyles.caption1
                                  .copyWith(color: AppColors.grayLight)),
                        ),
                        if (canDelete)
                          TextButton(
                            onPressed: () => _deleteComment(commentId),
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.only(left: 12)),
                            child: Text('Delete',
                                style: AppTextStyles.caption1
                                    .copyWith(color: AppColors.grayLight)),
                          ),
                      ],
                    ),
                    if (replyCount > 0)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _repliesExpanded[commentId] = !expanded;
                          });
                        },
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(
                          expanded
                              ? 'Hide replies ($replyCount)'
                              : 'Show replies ($replyCount)',
                          style: AppTextStyles.caption1
                              .copyWith(color: AppColors.grayLight),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (expanded && replies.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: depth == 0 ? 28 : 0, top: 6),
              child: Column(
                children: replies
                    .map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildCommentTile(
                            Map<String, dynamic>.from(r as Map),
                            isReply: true,
                            depth: depth + 1,
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
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
