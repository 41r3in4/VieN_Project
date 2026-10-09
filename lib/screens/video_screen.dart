import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../services/local_service.dart';
import 'camera_screen.dart';

class VideoTrailerScreen extends StatefulWidget {
  final LocalService localService;
  final String activeCity;

  const VideoTrailerScreen({
    super.key,
    required this.localService,
    this.activeCity = 'Chưa xác định',
  });

  @override
  State<VideoTrailerScreen> createState() => _VideoTrailerScreenState();
}

class _VideoTrailerScreenState extends State<VideoTrailerScreen> {
  late final VideoPlayerController _controller;
  bool _isInitialized = false;

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
      _controller.setLooping(true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTask() async {
    await _controller.pause();
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CameraTaskScreen(
          localService: widget.localService,
          activeCity: widget.activeCity,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                onPressed: _handleTask,
                icon: const Icon(Icons.camera_alt),
                label: const Text('NHẬP VAI: CHỤP ẢNH LÀM NHIỆM VỤ ⚔️'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
