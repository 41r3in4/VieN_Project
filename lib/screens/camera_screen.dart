import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/local_service.dart';
import 'home_screen.dart';

class CameraTaskScreen extends StatefulWidget {
  final LocalService localService;
  final String activeCity;

  const CameraTaskScreen({
    super.key,
    required this.localService,
    this.activeCity = 'Chưa xác định',
  });

  @override
  State<CameraTaskScreen> createState() => _CameraTaskScreenState();
}

class _CameraTaskScreenState extends State<CameraTaskScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<_HeritageTask> _tasks = [
    const _HeritageTask(
      id: 'task_0',
      city: 'Thừa Thiên Huế',
      title: 'Chụp ảnh check-in Ngọ Môn Huế',
      description: 'Khởi động hành trình khảo cổ tại cổng Hoàng Thành',
      rewardPoints: 100,
      icon: Icons.camera_alt,
    ),
    const _HeritageTask(
      id: 'task_1',
      city: 'Đà Nẵng',
      title: 'Quét cổ vật tại Bảo tàng Cổ vật Cung đình',
      description: 'Đánh dấu di sản bằng dấu vân tay trí tuệ',
      rewardPoints: 150,
      icon: Icons.museum,
    ),
    const _HeritageTask(
      id: 'task_2',
      city: 'Thừa Thiên Huế',
      title: 'Giải mã câu đố lịch sử tại điện Thái Hòa',
      description: 'Mở khóa ký ức triều Nguyễn qua trò chơi thông minh',
      rewardPoints: 200,
      icon: Icons.quiz,
    ),
  ];
  XFile? _image;
  bool _hasAppliedFilter = false;
  int _selectedTaskIndex = 0;
  List<String> _completedTaskIds = <String>[];
  String _activeCity = 'Chưa xác định';

  @override
  void initState() {
    super.initState();
    _activeCity = widget.activeCity;
    _loadCompletedTasks();
    _loadActiveCity();
  }

  Future<void> _loadCompletedTasks() async {
    final completedTaskIds = await widget.localService.getCompletedTaskIds();
    if (!mounted) return;
    setState(() {
      _completedTaskIds = completedTaskIds;
      _selectedTaskIndex = _getNextAvailableTaskIndex();
    });
  }

  Future<void> _loadActiveCity() async {
    final city = await widget.localService.getActiveCity();
    if (!mounted) return;
    setState(() {
      _activeCity = city.isEmpty ? widget.activeCity : city;
      _updateSelectedTaskForVisibleList();
    });
  }

  bool _isTaskVisibleForCity(_HeritageTask task) {
    if (_activeCity == 'Thừa Thiên Huế') {
      return task.city == 'Thừa Thiên Huế';
    }
    if (_activeCity == 'Quảng Nam') {
      return task.city == 'Quảng Nam';
    }
    if (_activeCity == 'Đà Nẵng') {
      return task.city == 'Đà Nẵng';
    }
    return false;
  }

  int _getNextAvailableTaskIndex() {
    for (int index = 0; index < _tasks.length; index++) {
      final task = _tasks[index];
      if (!_isTaskVisibleForCity(task)) {
        continue;
      }
      if (!_completedTaskIds.contains(task.id)) {
        return index;
      }
    }
    return _tasks.indexWhere((task) => _isTaskVisibleForCity(task));
  }

  void _updateSelectedTaskForVisibleList() {
    final visibleTaskIndex = _tasks.indexWhere((task) {
      return _isTaskVisibleForCity(task) &&
          task.id == _tasks[_selectedTaskIndex].id;
    });
    if (visibleTaskIndex >= 0) {
      _selectedTaskIndex = visibleTaskIndex;
      return;
    }

    final nextIndex = _getNextAvailableTaskIndex();
    if (nextIndex >= 0) {
      _selectedTaskIndex = nextIndex;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    setState(() {
      _image = pickedFile;
      _hasAppliedFilter = false;
    });
  }

  Widget _buildPreviewImage() {
    final image = _image;
    if (image == null || image.path.isEmpty) {
      return const Center(child: Text('Chưa có ảnh để xem trước'));
    }

    if (kIsWeb) {
      return Image.network(
        image.path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image_outlined, size: 48),
          );
        },
      );
    }

    return Image.file(
      File(image.path),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(child: Icon(Icons.broken_image_outlined, size: 48));
      },
    );
  }

  Future<void> _submitEvidence() async {
    if (_image == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chụp ảnh trước khi nộp minh chứng.'),
        ),
      );
      return;
    }

    final selectedTask = _tasks[_selectedTaskIndex];
    final userData = await widget.localService.getUserData();
    final updatedPoints = userData.points + selectedTask.rewardPoints;
    await widget.localService.saveUserData(userData.email, updatedPoints);

    final completedAt =
        '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}';
    await widget.localService.markTaskCompleted(
      taskId: selectedTask.id,
      title: selectedTask.title,
      points: selectedTask.rewardPoints,
      completedAt: completedAt,
    );

    if (!mounted) return;
    setState(() {
      if (!_completedTaskIds.contains(selectedTask.id)) {
        _completedTaskIds.add(selectedTask.id);
      }
      _selectedTaskIndex = _getNextAvailableTaskIndex();
    });

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nhiệm Vụ Hoàn Thành! 🎉'),
        content: Text(
          'Bạn đã hoàn thành "${selectedTask.title}" và nhận +${selectedTask.rewardPoints} điểm. Tổng điểm hiện tại: $updatedPoints',
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  Widget _buildTaskBoard() {
    final visibleTasks = _tasks.asMap().entries.where((entry) {
      return _isTaskVisibleForCity(entry.value);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BẢNG NHIỆM VỤ DI SẢN',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'Địa điểm đang kích hoạt: $_activeCity',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        if (visibleTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text('Vùng khác - Hãy di chuyển đến để kích hoạt.'),
          )
        else
          ...visibleTasks.map((entry) {
            final index = entry.key;
            final task = entry.value;
            final isCompleted = _completedTaskIds.contains(task.id);
            final isLocked =
                !isCompleted && index > _getNextAvailableTaskIndex();
            final isSelected = index == _selectedTaskIndex;
            final canSelect = !isCompleted && !isLocked;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: canSelect
                    ? () => setState(() => _selectedTaskIndex = index)
                    : null,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFFE8F5E9)
                        : isSelected
                        ? const Color(0xFFFFE0B2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCompleted
                          ? Colors.green.shade600
                          : isSelected
                          ? Colors.deepOrange
                          : Colors.grey.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.deepOrange.shade100,
                        child: Icon(task.icon, color: Colors.deepOrange),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              task.description,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '+${task.rewardPoints} điểm',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isCompleted
                                ? 'Đã hoàn thành'
                                : isLocked
                                ? 'Đang chờ mở khóa'
                                : 'Có thể làm tiếp',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isCompleted
                                  ? Colors.green.shade700
                                  : isLocked
                                  ? Colors.grey.shade600
                                  : Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildCapturePrompt() {
    final selectedTaskTitle =
        _selectedTaskIndex >= 0 && _selectedTaskIndex < _tasks.length
        ? _tasks[_selectedTaskIndex].title
        : 'Không có nhiệm vụ phù hợp cho khu vực này';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.camera_alt, size: 72, color: Colors.deepOrange),
            const SizedBox(height: 16),
            const Text(
              'Chụp ảnh để xác minh nhiệm vụ di tích',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'Nhiệm vụ hiện tại: $selectedTaskTitle',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera),
              label: const Text('MỞ CAMERA CHỤP ẢNH'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        title: const Text('Nhiệm vụ ảnh'),
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
                _buildTaskBoard(),
                const SizedBox(height: 20),
                if (_image == null)
                  _buildCapturePrompt()
                else
                  Column(
                    children: [
                      SizedBox(
                        height: 320,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: _hasAppliedFilter
                                  ? ColorFiltered(
                                      colorFilter:
                                          const ColorFilter.matrix(<double>[
                                            1.2,
                                            0.0,
                                            0.0,
                                            0.0,
                                            0.0,
                                            0.0,
                                            0.95,
                                            0.0,
                                            0.0,
                                            0.0,
                                            0.0,
                                            0.0,
                                            0.7,
                                            0.0,
                                            0.0,
                                            0.0,
                                            0.0,
                                            0.0,
                                            0.0,
                                            1.0,
                                            0.0,
                                          ]),
                                      child: _buildPreviewImage(),
                                    )
                                  : _buildPreviewImage(),
                            ),
                            if (_hasAppliedFilter)
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'ĐẠI NỘI HUẾ • VieN Check-in',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  setState(() => _hasAppliedFilter = true),
                              icon: const Icon(Icons.auto_awesome),
                              label: const Text('ÁP DỤNG FILTER AI GỢI Ý'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _submitEvidence,
                              icon: const Icon(Icons.check_circle),
                              label: const Text('NỘP MINH CHỨNG & TÍCH ĐIỂM'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeritageTask {
  final String id;
  final String city;
  final String title;
  final String description;
  final int rewardPoints;
  final IconData icon;

  const _HeritageTask({
    required this.id,
    required this.city,
    required this.title,
    required this.description,
    required this.rewardPoints,
    required this.icon,
  });
}
