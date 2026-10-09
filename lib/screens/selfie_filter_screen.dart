import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/local_service.dart';
import 'exploration_tasks_screen.dart';

class SelfieFilterScreen extends StatefulWidget {
  final LocalService localService;
  final String attractionTitle;

  const SelfieFilterScreen({
    super.key,
    required this.localService,
    required this.attractionTitle,
  });

  @override
  State<SelfieFilterScreen> createState() => _SelfieFilterScreenState();
}

class _SelfieFilterScreenState extends State<SelfieFilterScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _capturedImage;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _takePhoto());
  }

  Future<void> _takePhoto() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    final image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (!mounted) return;
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa chụp ảnh, hãy thử lại.')),
      );
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _capturedImage = image;
      _isCapturing = false;
    });
  }

  Widget _buildPreview() {
    final image = _capturedImage;
    if (image == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.amber),
      );
    }

    final useNetworkPreview =
        kIsWeb ||
        image.path.startsWith('http') ||
        image.path.startsWith('blob:');

    return Stack(
      children: [
        Positioned.fill(
          child: useNetworkPreview
              ? Image.network(
                  image.path,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image_outlined, size: 48),
                    );
                  },
                )
              : Image.file(
                  File(image.path),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image_outlined, size: 48),
                    );
                  },
                ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.amber.shade200, width: 6),
              borderRadius: BorderRadius.circular(28),
            ),
            margin: const EdgeInsets.all(20),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.08),
                          Colors.deepOrange.withOpacity(0.16),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Positioned(
                  top: 18,
                  left: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Khung ảnh Cung Đình Huế',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 22,
                  left: 18,
                  right: 18,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Bóng rồng, vàng hoàng gia và nét cổ kính của Huế hiện lên trên khung ảnh của bạn.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _closeSelfieFlow() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ExplorationTasksScreen(
          localService: widget.localService,
          attractionTitle: widget.attractionTitle,
          showSelfieOverlay: true,
        ),
      ),
    );
  }

  void _saveAndContinue() {
    if (_capturedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chụp ảnh trước khi lưu.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ảnh selfie đã được lưu thành công.')),
    );

    _closeSelfieFlow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Selfie Cung Đình Huế'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            tooltip: 'Quay lại nhiệm vụ',
            onPressed: _closeSelfieFlow,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildPreview()),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              color: const Color(0xFF2A1A0F),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Chụp lại'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amber,
                        side: const BorderSide(color: Colors.amber),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveAndContinue,
                      icon: const Icon(Icons.save_alt),
                      label: const Text('Chụp & Lưu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                      ),
                    ),
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
