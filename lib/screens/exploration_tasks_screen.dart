import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../services/local_service.dart';
import 'main_container_screen.dart';

class ExplorationTasksScreen extends StatefulWidget {
  final LocalService localService;
  final String attractionTitle;
  final bool showSelfieOverlay;

  const ExplorationTasksScreen({
    super.key,
    required this.localService,
    required this.attractionTitle,
    this.showSelfieOverlay = false,
  });

  @override
  State<ExplorationTasksScreen> createState() => _ExplorationTasksScreenState();
}

class _ExplorationTasksScreenState extends State<ExplorationTasksScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _showSelfieOverlay = false;
  bool _showQuizResult = false;
  String? _quizFeedback;
  final List<_TaskItem> _tasks = const [
    _TaskItem(
      title: 'Chụp ảnh check-in Cửu Đỉnh',
      type: 'photo',
      rewardPoints: 120,
      description: 'Ghi lại khoảnh khắc cùng Đại Nội Huế',
      videoUrl:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      historyTitle: 'Cửu Đỉnh History',
    ),
    _TaskItem(
      title: 'Vua nào cho xây dựng Kinh thành Huế?',
      type: 'quiz',
      rewardPoints: 80,
      description: 'Chọn đáp án đúng để nhận điểm',
      videoUrl: 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4',
      historyTitle: 'Kinh Thành Huế History',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _showSelfieOverlay = widget.showSelfieOverlay;
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    setState(() {
      _image = picked;
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

  Future<void> _playMissionVideo(_TaskItem task) async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _MissionVideoScreen(
          videoUrl: task.videoUrl,
          title: task.historyTitle,
        ),
      ),
    );
  }

  Future<void> _submitPhotoTask() async {
    if (_image == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chụp ảnh trước khi nộp nhiệm vụ.'),
        ),
      );
      return;
    }

    final task = _tasks.firstWhere((item) => item.type == 'photo');
    final userData = await widget.localService.getUserData();
    final updatedPoints = userData.points + task.rewardPoints;
    await widget.localService.saveUserData(userData.email, updatedPoints);
    await widget.localService.markTaskCompleted(
      taskId: 'hue_photo_${widget.attractionTitle}',
      title: 'Chụp ảnh check-in ${widget.attractionTitle}',
      points: task.rewardPoints,
      completedAt:
          '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
    );

    if (!mounted) return;
    setState(() {
      _showQuizResult = true;
      _quizFeedback = 'Ảnh đã được lưu. Bạn nhận ${task.rewardPoints} điểm.';
    });
    await _playMissionVideo(task);
  }

  Future<void> _submitQuizAnswer(String answer) async {
    final task = _tasks.firstWhere((item) => item.type == 'quiz');
    if (answer == 'Gia Long') {
      final userData = await widget.localService.getUserData();
      final updatedPoints = userData.points + task.rewardPoints;
      await widget.localService.saveUserData(userData.email, updatedPoints);
      await widget.localService.markTaskCompleted(
        taskId: 'hue_quiz_${widget.attractionTitle}',
        title: 'Quiz ${widget.attractionTitle}',
        points: task.rewardPoints,
        completedAt:
            '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
      );
      if (!mounted) return;
      setState(() {
        _showQuizResult = true;
        _quizFeedback = 'Đúng rồi! Bạn nhận ${task.rewardPoints} điểm.';
      });
      await _playMissionVideo(task);
      return;
    }

    if (!mounted) return;
    setState(() {
      _showQuizResult = true;
      _quizFeedback = 'Chưa đúng rồi. Hãy thử lại!';
    });
  }

  Future<void> _finishJourney() async {
    final userData = await widget.localService.getUserData();
    if (!mounted) return;
    await widget.localService.saveUserData(userData.email, userData.points);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hành trình đã kết thúc'),
        content: Text(
          'Bạn đã hoàn tất hành trình tại ${widget.attractionTitle}. Tổng điểm hiện tại: ${userData.points}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MainContainerScreen(localService: widget.localService),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        title: const Text('Nhiệm vụ khám phá'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            tooltip: 'Quay lại Huế',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) =>
                      MainContainerScreen(localService: widget.localService),
                ),
                (route) => false,
              );
            },
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
                if (_showSelfieOverlay)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.camera_alt, color: Colors.deepOrange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Khung selfie đã mở sẵn để bạn ghi lại khoảnh khắc tại đây.',
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Nhiệm vụ cho ${widget.attractionTitle}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 12),
                ..._tasks.map(
                  (task) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.deepOrange.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(task.description),
                        const SizedBox(height: 10),
                        if (task.type == 'photo') ...[
                          if (_image == null)
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Chụp ảnh'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                foregroundColor: Colors.white,
                              ),
                            )
                          else
                            Column(
                              children: [
                                SizedBox(
                                  height: 180,
                                  child: _buildPreviewImage(),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _submitPhotoTask,
                                  icon: const Icon(Icons.check_circle),
                                  label: const Text('Nộp nhiệm vụ ảnh'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                        ] else ...[
                          Wrap(
                            spacing: 8,
                            children: [
                              ElevatedButton(
                                onPressed: () => _submitQuizAnswer('Gia Long'),
                                child: const Text('Gia Long'),
                              ),
                              ElevatedButton(
                                onPressed: () => _submitQuizAnswer('Minh Mạng'),
                                child: const Text('Minh Mạng'),
                              ),
                              ElevatedButton(
                                onPressed: () => _submitQuizAnswer('Khải Định'),
                                child: const Text('Khải Định'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (_showQuizResult)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(_quizFeedback ?? 'Đã hoàn thành.'),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _finishJourney,
                    icon: const Icon(Icons.flag_circle),
                    label: const Text('KẾT THÚC HÀNH TRÌNH'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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

class _TaskItem {
  final String title;
  final String type;
  final int rewardPoints;
  final String description;
  final String videoUrl;
  final String historyTitle;

  const _TaskItem({
    required this.title,
    required this.type,
    required this.rewardPoints,
    required this.description,
    required this.videoUrl,
    required this.historyTitle,
  });
}

class _MissionVideoScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const _MissionVideoScreen({required this.videoUrl, required this.title});

  @override
  State<_MissionVideoScreen> createState() => _MissionVideoScreenState();
}

class _MissionVideoScreenState extends State<_MissionVideoScreen> {
  late final VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isVideoFinished = false;

  @override
  void initState() {
    super.initState();
    final shouldInitializeVideo = !Platform.environment.containsKey(
      'FLUTTER_TEST',
    );
    if (!shouldInitializeVideo) {
      setState(() => _isInitialized = true);
      return;
    }

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _isInitialized = true);
      _controller.play();
      _controller.setLooping(false);
      _controller.addListener(_onVideoStateChanged);
    });
  }

  void _onVideoStateChanged() {
    if (_controller.value.position >= _controller.value.duration &&
        _controller.value.duration > Duration.zero) {
      if (!_isVideoFinished) {
        _isVideoFinished = true;
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (_isInitialized)
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              ),
            Positioned(
              top: 24,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.skip_next),
                label: const Text('BỪA QUA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
