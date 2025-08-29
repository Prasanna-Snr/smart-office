import 'package:flutter/material.dart';
import 'live_mjpeg_view.dart';

class CameraView extends StatefulWidget {
  final VoidCallback? onFaceRecognition;

  const CameraView({
    Key? key,
    this.onFaceRecognition,
  }) : super(key: key);

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final GlobalKey<LiveMjpegViewState> _cameraKey = GlobalKey<LiveMjpegViewState>();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: LiveMjpegView(
        key: _cameraKey,
        height: 190,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
    );
  }
}