import 'package:flutter/material.dart';

import '../services/local_service.dart';
import 'exploration_tasks_screen.dart';

class HeritageHistoryScreen extends StatelessWidget {
  final LocalService localService;
  final String attractionTitle;
  final String taskTitle;

  const HeritageHistoryScreen({
    super.key,
    required this.localService,
    required this.attractionTitle,
    required this.taskTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        title: const Text('Thông tin lịch sử di sản'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            tooltip: 'Quay lại nhiệm vụ',
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ExplorationTasksScreen(
                  localService: localService,
                  attractionTitle: attractionTitle,
                ),
              ),
            ),
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFFC107)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attractionTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nhiệm vụ hoàn thành: $taskTitle',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Câu chuyện và bối cảnh lịch sử',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 12),
                _HistoryCard(
                  title: 'Di sản vô giá',
                  body:
                      'Địa điểm này là một phần của hệ thống cung điện, chùa chiền và lăng tẩm đã góp phần làm nên nét riêng của Huế trong suốt nhiều thế kỷ.',
                ),
                const SizedBox(height: 12),
                _HistoryCard(
                  title: 'Bối cảnh triều Nguyễn',
                  body:
                      'Trong thời kỳ trị vì của các vua Nguyễn, Huế được lựa chọn làm kinh đô, nơi hội tụ nghệ thuật, kiến trúc và nghi lễ cung đình.',
                ),
                const SizedBox(height: 12),
                _HistoryCard(
                  title: 'Ý nghĩa hiện đại',
                  body:
                      'Ngày nay, mỗi bước chân tại đây không chỉ là chuyến tham quan mà còn là cách nối lại câu chuyện về bản sắc và ký ức cộng đồng.',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => ExplorationTasksScreen(
                            localService: localService,
                            attractionTitle: attractionTitle,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.explore),
                    label: const Text('Tiếp Tục Khám Phá'),
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
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String title;
  final String body;

  const _HistoryCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepOrange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(body),
        ],
      ),
    );
  }
}
