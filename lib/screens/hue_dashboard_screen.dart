import 'package:flutter/material.dart';

import '../services/local_service.dart';
import 'attraction_detail_screen.dart';

class HueDashboardScreen extends StatefulWidget {
  final LocalService localService;

  const HueDashboardScreen({super.key, required this.localService});

  @override
  State<HueDashboardScreen> createState() => _HueDashboardScreenState();
}

class _HueDashboardScreenState extends State<HueDashboardScreen> {
  final TextEditingController _chatController = TextEditingController();
  final List<_HueSpot> _spots = const [
    _HueSpot(
      title: 'Đại Nội Huế',
      subtitle: 'Kinh thành và di tích triều Nguyễn',
      icon: Icons.account_balance,
    ),
    _HueSpot(
      title: 'Chùa Thiên Mụ',
      subtitle: 'Ngọn tháp linh thiêng bên sông Hương',
      icon: Icons.temple_buddhist,
    ),
    _HueSpot(
      title: 'Lăng Tự Đức',
      subtitle: 'Cảnh quan thiên nhiên và kiến trúc cổ',
      icon: Icons.landscape,
    ),
  ];

  final List<_HueChatMessage> _messages = [
    const _HueChatMessage(
      user: 'Hoàng',
      text: 'Mọi người đã check-in Chùa Thiên Mụ chưa?',
      location: 'Huế',
    ),
    const _HueChatMessage(
      user: 'An',
      text: 'Mới hoàn thành xong nhiệm vụ Đại Nội nè!',
      location: 'Huế',
    ),
  ];

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_HueChatMessage(user: 'Bạn', text: text, location: 'Huế'));
      _chatController.clear();
    });
  }

  Future<void> _verifyLocation(_HueSpot spot) async {
    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFFFF8E1),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.deepOrange),
              const SizedBox(height: 16),
              Text(
                'Hệ thống đang xác thực tọa độ GPS của bạn tại ${spot.title}...',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );

    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Xác thực thành công!'),
          content: const Text(
            'Xác thực thành công! Bạn đã đến đúng vị trí di sản. 🎉',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AttractionDetailScreen(
                      localService: widget.localService,
                      attractionTitle: spot.title,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Bắt đầu khám phá'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        title: const Text('Thành phố Huế'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFFC107)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Khám phá Huế bằng các nhiệm vụ, câu chuyện và cộng đồng địa phương.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Điểm đến nổi bật',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 12),
                ..._spots.map(
                  (spot) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => _verifyLocation(spot),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.deepOrange.shade100),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.amber.shade100,
                              child: Icon(spot.icon, color: Colors.deepOrange),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    spot.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    spot.subtitle,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Cộng đồng Huế',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.deepOrange.shade100),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${message.user} • ${message.location}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(message.text),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              decoration: const InputDecoration(
                                hintText: 'Nhắn với cộng đồng Huế...',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _sendMessage,
                            icon: const Icon(Icons.send),
                            label: const Text('Gửi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _HueSpot {
  final String title;
  final String subtitle;
  final IconData icon;

  const _HueSpot({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _HueChatMessage {
  final String user;
  final String text;
  final String location;

  const _HueChatMessage({
    required this.user,
    required this.text,
    required this.location,
  });
}
