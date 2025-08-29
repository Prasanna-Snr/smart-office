import 'package:flutter/material.dart';
import 'live_mjpeg_view.dart';

class CameraView extends StatelessWidget {
  final VoidCallback? onFaceRecognition;

  const CameraView({
    Key? key,
    this.onFaceRecognition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: const LiveMjpegView(
        height: 190,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    );
  }
}