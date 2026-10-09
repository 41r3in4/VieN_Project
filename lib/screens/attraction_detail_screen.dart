import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../services/local_service.dart';
import 'exploration_tasks_screen.dart';
import 'selfie_filter_screen.dart';

class AttractionDetailScreen extends StatefulWidget {
  final LocalService localService;
  final String attractionTitle;

  const AttractionDetailScreen({
    super.key,
    required this.localService,
    required this.attractionTitle,
  });

  @override
  State<AttractionDetailScreen> createState() => _AttractionDetailScreenState();
}

class _AttractionDetailScreenState extends State<AttractionDetailScreen> {
  late final VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _videoCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      ),
    );
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
      _controller.play();
      _controller.setLooping(false);
      _controller.addListener(_onVideoStateChanged);
    });
  }

  void _onVideoStateChanged() {
    if (_controller.value.position >= _controller.value.duration &&
        _controller.value.duration > Duration.zero) {
      if (!_videoCompleted) {
        _videoCompleted = true;
        _showSelfiePrompt();
      }
    }
  }

  Future<void> _showSelfiePrompt() async {
    if (!mounted) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chụp ảnh tự sướng?'),
        content: const Text(
          'Bạn có muốn chụp ảnh tự sướng cùng địa điểm ở đây không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (result == true) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SelfieFilterScreen(
            localService: widget.localService,
            attractionTitle: widget.attractionTitle,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExplorationTasksScreen(
            localService: widget.localService,
            attractionTitle: widget.attractionTitle,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.attractionTitle),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            tooltip: 'Quay lại',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Stack(
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
            const Center(child: CircularProgressIndicator(color: Colors.amber)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _controller.pause();
                  if (!mounted) return;
                  _showSelfiePrompt();
                },
                icon: const Icon(Icons.skip_next),
                label: const Text('BỪA QUA VIDEO GIỚI THIỆU'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
