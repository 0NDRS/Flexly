import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/services/analysis_service.dart';
import 'package:flexly/pages/analysis_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:flexly/widgets/home/user_search_delegate.dart';
import 'package:flexly/pages/user_profile_page.dart';
import 'package:flexly/services/auth_service.dart';
import 'package:flexly/services/event_bus.dart';
import 'dart:async';

class FeedTab extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const FeedTab({super.key, this.onNavigateToTab});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  final _analysisService = AnalysisService();
  final _authService = AuthService();
  final _scrollController = ScrollController();

  List<dynamic> _feedItems = [];
  bool _isLoading = true;
  String? _currentUserId;


  int _currentPage = 1;
  final int _limit = 10;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadFeed();
    _scrollController.addListener(_onScroll);
    _eventSubscription = EventBus().stream.listen((event) {
      if (event is AnalysisDeletedEvent) {
        _loadFeed();
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getUser();
    if (mounted && user != null) {
      setState(() {
        _currentUserId = user['_id'];
      });
    }
  }

  Future<void> _loadFeed() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _hasMore = true;
        _feedItems = [];
      });
    }

    try {
      final items =
          await _analysisService.getFeed(page: _currentPage, limit: _limit);
      if (mounted) {
        setState(() {
          _feedItems = items;
          _isLoading = false;
          if (items.length < _limit) {
            _hasMore = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    if (mounted) {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final nextPage = _currentPage + 1;
      final newItems =
          await _analysisService.getFeed(page: nextPage, limit: _limit);

      if (mounted) {
        setState(() {
          if (newItems.isNotEmpty) {
            _feedItems.addAll(newItems);
            _currentPage = nextPage;
          }

          if (newItems.length < _limit) {
            _hasMore = false;
          }
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showSearch(context: context, delegate: UserSearchDelegate());
          _loadFeed();
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.search, color: Colors.white),
      ),
      body: _feedItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_outlined,
                      size: 64, color: AppColors.grayLight),
                  const SizedBox(height: 16),
                  Text(
                    'Your feed is empty',
                    style:
                        AppTextStyles.h3.copyWith(color: AppColors.grayLight),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Follow people to see their posts here',
                    style: AppTextStyles.body2
                        .copyWith(color: AppColors.grayLight),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      await showSearch(
                          context: context, delegate: UserSearchDelegate());
                      _loadFeed();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Find People'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadFeed,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _feedItems.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _feedItems.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return _buildFeedCard(_feedItems[index]);
                },
              ),
            ),
    );
  }

  Widget _buildFeedCard(Map<String, dynamic> item) {
    final user = item['user'] ?? {};
    final imageUrls =
        (item['imageUrls'] as List).map((e) => e.toString()).toList();
    final firstImage = imageUrls.isNotEmpty ? imageUrls[0] : null;
    final ratings = item['ratings'] as Map<String, dynamic>;
    final overall = (ratings['overall'] as num).toDouble();
    final date = DateTime.parse(item['createdAt']);
    final formattedDate = DateFormat.yMMMd().format(date);

    Future<void> openDetail() async {
      final bodyParts = Map<String, double>.fromEntries(
        ratings.entries
            .where((e) => e.key != 'overall')
            .map((e) => MapEntry(e.key, (e.value as num).toDouble())),
      );

      if (context.mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisDetailPage(
              date: formattedDate,
              overallRating: overall,
              bodyPartRatings: bodyParts,
              adviceTitle: item['adviceTitle'] ?? 'Analysis',
              adviceDescription: item['advice'] ?? '',
              imageUrls: imageUrls,
              isMe: user['_id'] == _currentUserId,
              analysisId: item['_id'],
            ),
          ),
        );

        if (result == true) {
          _loadFeed();
        }
      }
    }

    return GestureDetector(
      onTap: openDetail,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: AppColors.grayDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gray, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (_currentUserId != null &&
                          user['_id'] == _currentUserId) {
                        widget.onNavigateToTab?.call(4);
                        return;
                      }

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserProfilePage(userId: user['_id']),
                        ),
                      );
                      _loadFeed();
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.grayLight,
                      backgroundImage: user['profilePicture'] != null &&
                              user['profilePicture'].isNotEmpty
                          ? NetworkImage(user['profilePicture'])
                          : null,
                      child: user['profilePicture'] == null ||
                              user['profilePicture'].isEmpty
                          ? const Icon(Icons.person,
                              color: Colors.white, size: 20)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'] ?? 'User',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: AppTextStyles.caption2
                            .copyWith(color: AppColors.grayLight),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          overall.toStringAsFixed(1),
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (firstImage != null)
              Stack(
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(firstImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: openDetail,
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child:
                              Icon(Icons.link, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item['adviceTitle'] != null)
                    Text(
                      item['adviceTitle'],
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    item['advice'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body2
                        .copyWith(color: AppColors.grayLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
