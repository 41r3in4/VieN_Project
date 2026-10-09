import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/user_data.dart';
import '../services/local_service.dart';
import 'community_chat_screen.dart';
import 'hue_dashboard_screen.dart';
import 'login_screen.dart';
import 'video_screen.dart';

class HomeScreen extends StatefulWidget {
  final LocalService localService;

  const HomeScreen({super.key, required this.localService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserData? _userData;
  bool _isCheckingIn = false;
  String _activeCity = 'Chưa xác định';
  final List<_TravelHistoryItem> _defaultTravelHistory = const [
    _TravelHistoryItem(
      title: '📍 Phố cổ Hội An (Quảng Nam)',
      subtitle: 'Hoàn thành 24/06/2026',
      points: '+150 pts',
    ),
    _TravelHistoryItem(
      title: '📍 Danh thắng Ngũ Hành Sơn (Đà Nẵng)',
      subtitle: 'Hoàn thành 23/06/2026',
      points: '+100 pts',
    ),
    _TravelHistoryItem(
      title: '📍 Kỳ Đài Huế',
      subtitle: 'Hoàn thành 20/06/2026',
      points: '+50 pts',
    ),
    _TravelHistoryItem(
      title: '🎭 Đêm Hoàng Cung',
      subtitle: 'Hoàn thành 22/06/2026',
      points: '+100 pts',
    ),
  ];
  List<_TravelHistoryItem> _travelHistory = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTravelHistory();
    _loadActiveCity();
  }

  Future<void> _loadUserData() async {
    final userData = await widget.localService.getUserData();
    if (!mounted) return;
    setState(() => _userData = userData);
  }

  Future<void> _loadTravelHistory() async {
    final history = await widget.localService.getTravelHistory();
    if (!mounted) return;
    setState(() {
      _travelHistory = [
        ...history.map(
          (item) => _TravelHistoryItem(
            title: item['title'] as String,
            subtitle: 'Hoàn thành ${item['completedAt'] as String}',
            points: '+${item['points']} pts',
          ),
        ),
        ..._defaultTravelHistory,
      ];
    });
  }

  Future<void> _loadActiveCity() async {
    final city = await widget.localService.getActiveCity();
    if (!mounted) return;
    setState(() => _activeCity = city.isEmpty ? 'Chưa xác định' : city);
  }

  Future<void> _handleCheckIn() async {
    setState(() => _isCheckingIn = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    await widget.localService.saveActiveCity('Thừa Thiên Huế');
    if (!mounted) return;
    setState(() => _activeCity = 'Thừa Thiên Huế');

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận vị trí'),
        content: const Text('Đã xác nhận: Bạn đang ở ĐẠI NỘI HUẾ! 📍'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HueDashboardScreen(localService: widget.localService),
      ),
    );

    if (!mounted) return;
    setState(() => _isCheckingIn = false);
  }

  Future<void> _handleLogout() async {
    await widget.localService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginScreen(localService: widget.localService),
      ),
      (route) => false,
    );
  }

  int _calculateDisplayPoints(List<_TravelHistoryItem> travelHistory) {
    final historyPoints = travelHistory.fold<int>(0, (sum, item) {
      final parsed = int.tryParse(
        item.points.replaceAll(RegExp(r'[^0-9-]'), ''),
      );
      return sum + (parsed ?? 0);
    });
    return historyPoints;
  }

  Widget _buildFeaturedEvents() {
    final events = _activeCity == 'Thừa Thiên Huế'
        ? [
            _FeaturedEventCard(
              title: '🎭 Festival Huế 2026',
              subtitle: 'Tinh hoa di sản văn hóa trong mùa lễ hội đặc sắc',
            ),
            _FeaturedEventCard(
              title: '🎵 Đêm ca Huế trên sông Hương',
              subtitle: 'Giảm 20% cho Đội Viên VieN',
            ),
          ]
        : [
            _FeaturedEventCard(
              title: '🏛️ Khám phá thành phố của bạn',
              subtitle:
                  'Hãy check-in để mở các sự kiện nổi bật tại khu vực đang hiện diện',
            ),
          ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SỰ KIỆN NỔI BẬT TẠI THÀNH PHỐ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 12),
            ...events.map(
              (event) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(event.subtitle, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = _userData;
    final theme = Theme.of(context);
    final travelHistory = _travelHistory.isEmpty
        ? _defaultTravelHistory
        : _travelHistory;
    final historyPoints = _calculateDisplayPoints(travelHistory);
    final points = ((userData?.points ?? 0) > historyPoints)
        ? userData!.points
        : historyPoints;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        title: const Text('Ví Mạch Sử'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      CommunityChatScreen(userEmail: _userData?.email ?? ''),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            label: const Text(
              'Trò Chuyện Cộng Đồng',
              style: TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFFC107)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CHÀO MỪNG, ${userData?.email.toUpperCase() ?? 'NGƯỜI DU KHÁCH'}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Điểm hiện tại: $points điểm',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Danh hiệu: ${userData?.title ?? UserData.calculateTitle(points)}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HÀNH TRÌNH ĐÃ QUA',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...travelHistory.map(
                          (item) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF7EA),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.deepOrange.shade100,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.amber.shade100,
                                  child: const Icon(
                                    Icons.celebration,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        item.subtitle,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  item.points,
                                  style: const TextStyle(
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildFeaturedEvents(),
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.map_rounded,
                          size: 96,
                          color: Colors.deepOrange,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Bản đồ dẫn đường di tích',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Hệ thống radar lịch sử đang quét quanh Đại Nội Huế…',
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isCheckingIn ? null : _handleCheckIn,
                            icon: const Icon(Icons.gps_fixed),
                            label: Text(
                              _isCheckingIn
                                  ? 'Đang đồng bộ...'
                                  : 'QUÉT VỊ TRÍ (CHECK-IN)',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TravelHistoryItem {
  final String title;
  final String subtitle;
  final String points;

  const _TravelHistoryItem({
    required this.title,
    required this.subtitle,
    required this.points,
  });
}

class _FeaturedEventCard {
  final String title;
  final String subtitle;

  const _FeaturedEventCard({required this.title, required this.subtitle});
}
