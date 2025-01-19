import 'package:flutter/material.dart';
import '../../global/index.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final GlobalService _globalService = GetIt.I<GlobalService>();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      setState(() => _isLoading = true);

      final apartmentUid = PreferenceService.getApartmentUid();
      if (apartmentUid == null) {
        throw Exception('Apartment ID not found');
      }

      await _globalService.fetchNews(apartmentUid, DateTime.parse('2024-01-01'),
          DateTime.parse('2026-01-01'));
    } catch (e) {
      setState(() => _error = e.toString());
      debugPrint('Error fetching news: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Announcements'.tr(),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: GlobalConfig.primaryColor,
        ),
      );
    }

    if (_error != null) {
      return _buildErrorView();
    }

    return StreamBuilder<List<News>?>(
      stream: _globalService.news$.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return _buildEmptyView();
        }

        final news = snapshot.data!;
        if (news.isEmpty) {
          return _buildEmptyView();
        }

        // Sort news by start date in descending order
        news.sort((a, b) => b.startDate.compareTo(a.startDate));

        return _buildNewsList(news);
      },
    );
  }

  Widget _buildErrorView() {
    return RefreshIndicator(
      onRefresh: _initializeData,
      color: GlobalConfig.primaryColor,
      child: ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading announcements'.tr(),
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pull to refresh'.tr(),
                  style: AppTextStyles.bodyText.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return RefreshIndicator(
      onRefresh: _initializeData,
      color: GlobalConfig.primaryColor,
      child: ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No Announcements Found'.tr(),
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pull to refresh'.tr(),
                  style: AppTextStyles.bodyText.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList(List<News> news) {
    return RefreshIndicator(
      onRefresh: _initializeData,
      color: GlobalConfig.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: news.length,
        itemBuilder: (context, index) => _buildNewsCard(news[index]),
      ),
    );
  }

  Widget _buildNewsCard(News news) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: GlobalConfig.primaryColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.notifications,
                    color: GlobalConfig.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news.content,
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: 15,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDateRow(news),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(News news) {
    final startDate = DateTime.parse(news.startDate.toString());
    final endDate = DateTime.parse(news.endDate.toString());
    final dateFormat = DateFormat('dd MMM yyyy', 'tr_TR');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: 14,
            color: Colors.grey[800],
          ),
          const SizedBox(width: 6),
          Text(
            dateFormat.format(startDate),
            style: AppTextStyles.cardText.copyWith(
              color: Colors.grey[800],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '-',
              style: AppTextStyles.cardText.copyWith(
                color: Colors.grey[800],
              ),
            ),
          ),
          Text(
            dateFormat.format(endDate),
            style: AppTextStyles.cardText.copyWith(
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
