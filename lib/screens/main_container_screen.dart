import 'package:flutter/material.dart';

import '../models/user_data.dart';
import '../services/local_service.dart';
import 'hue_dashboard_screen.dart';
import 'login_screen.dart';

class MainContainerScreen extends StatefulWidget {
  final LocalService localService;

  const MainContainerScreen({super.key, required this.localService});

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF0E1723),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MẠNG LƯỚI DI SẢN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<UserData>(
                          future: widget.localService.getUserData(),
                          builder: (context, snapshot) {
                            final points = snapshot.data?.points ?? 400;
                            return Text(
                              '$points Điểm',
                              style: const TextStyle(
                                color: Color(0xFF00E5FF),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.wallet_giftcard,
                      color: Color(0xFF00E5FF),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  HueDashboardScreen(localService: widget.localService),
                  const _RankingBoardTab(),
                  const _RewardsShopTab(),
                  const _ProfileTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0E1723),
          border: Border(top: BorderSide(color: Color(0xFF1D2B3A), width: 1.0)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: const Color(0xFF0E1723),
          selectedItemColor: const Color(0xFF00E5FF),
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.layers_outlined),
              activeIcon: Icon(Icons.layers_rounded),
              label: 'MẠNG LƯỚI',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events),
              label: 'ĐẤU HẠNG',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard_outlined),
              activeIcon: Icon(Icons.card_giftcard),
              label: 'KHO QUÀ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'HỒ SƠ',
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingBoardTab extends StatelessWidget {
  const _RankingBoardTab();

  @override
  Widget build(BuildContext context) {
    final ranks = [('An', 980), ('Hoàng', 910), ('Mai', 860), ('Linh', 820)];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bảng xếp hạng cộng đồng',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 12),
          ...ranks.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final name = entry.value.$1;
            final score = entry.value.$2;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.deepOrange.shade100),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF00E5FF).withOpacity(0.16),
                    child: Text('$index'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '$score điểm',
                    style: const TextStyle(color: Colors.deepOrange),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _RewardsShopTab extends StatelessWidget {
  const _RewardsShopTab();

  @override
  Widget build(BuildContext context) {
    final rewards = [
      ('Mũ đội viên Huế', 180),
      ('Voucher bánh cốm', 260),
      ('Vé tham quan', 320),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kho quà hấp dẫn',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 12),
          ...rewards.map(
            (reward) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.deepOrange.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.card_giftcard, color: Color(0xFF00E5FF)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      reward.$1,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${reward.$2} điểm',
                    style: const TextStyle(color: Colors.deepOrange),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final localService = context
        .findAncestorWidgetOfExactType<MainContainerScreen>()
        ?.localService;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hồ sơ người tham gia',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.deepOrange.shade100),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tên: An', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('Vai trò: Người khám phá Huế'),
                SizedBox(height: 6),
                Text('Trạng thái: Đang tham gia 3 di sản'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'HÀNH TRÌNH ĐÃ QUA',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Đại Nội Huế'),
                SizedBox(height: 4),
                Text('• Chùa Thiên Mụ'),
                SizedBox(height: 4),
                Text('• Lăng Tự Đức'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await localService?.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(localService: localService!),
                    ),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text(
                'ĐĂNG XUẤT',
                style: TextStyle(color: Colors.redAccent),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
