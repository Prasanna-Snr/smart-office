import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/camera_service.dart';
import '../core/constants/app_constants.dart';

class LiveMjpegView extends StatefulWidget {
  final double height;
  final BorderRadius? borderRadius;

  const LiveMjpegView({
    super.key,
    required this.height,
    this.borderRadius,
  });

  @override
  State<LiveMjpegView> createState() => LiveMjpegViewState();
}

class LiveMjpegViewState extends State<LiveMjpegView> {
  final _httpClient = HttpClient()
    ..connectionTimeout = AppConstants.cameraConnectionTimeout;

  StreamSubscription<List<int>>? _sub;
  Uint8List? _currentFrame;

  String _status = 'Connecting...';
  String _currentUrl = '';
  bool _connecting = true;
  bool _hasError = false;

  // JPEG markers
  static const int _SOI0 = 0xFF;
  static const int _SOI1 = 0xD8;
  static const int _EOI0 = 0xFF;
  static const int _EOI1 = 0xD9;

  List<int> _buf = [];
  bool _inFrame = false;

  Timer? _watchdog;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _watchdog?.cancel();
    _sub?.cancel();
    _httpClient.close(force: true);
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    // First, try to find a working camera URL
    final workingUrl = await CameraService.findWorkingCameraUrl();
    
    if (workingUrl != null) {
      _currentUrl = workingUrl;
      _connect();
    } else {
      // Fallback to configured URL even if test failed
      _currentUrl = await CameraService.getCameraStreamUrl();
      _connect();
    }
  }

  void _setStatus(String s, {bool error = false}) {
    if (!mounted) return;
    setState(() {
      _status = s;
      _hasError = error;
    });
  }

  Future<void> _connect() async {
    _watchdog?.cancel();
    setState(() {
      _connecting = true;
      _hasError = false;
      _status = 'Connecting to camera...';
      _buf.clear();
      _inFrame = false;
    });

    if (_currentUrl.isEmpty) {
      _setStatus('Camera URL not available', error: true);
      return;
    }

    try {
      final uri = Uri.parse(_currentUrl);
      final req = await _httpClient.getUrl(uri);
      final res = await req.close();

      if (res.statusCode != 200) {
        _setStatus('HTTP ${res.statusCode} from camera', error: true);
        _scheduleReconnect();
        return;
      }

      _setStatus('Receiving stream...');
      _connecting = false;

      // Safety watchdog: if no bytes for 5s, reconnect.
      _watchdog = Timer.periodic(AppConstants.cameraWatchdogInterval, (_) {
        if (_currentFrame == null) {
          _setStatus('No frames received, retrying...', error: true);
          _reconnect();
        }
      });

      _sub = res.listen(
        _onBytes,
        onError: (e) {
          _setStatus('Stream error: $e', error: true);
          _scheduleReconnect();
        },
        onDone: () {
          _setStatus('Stream ended', error: true);
          _scheduleReconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      _setStatus('Connect failed: $e', error: true);
      _scheduleReconnect();
    }
  }

  void _reconnect() {
    _sub?.cancel();
    _watchdog?.cancel();
    _connect();
  }

  void _scheduleReconnect() {
    Future.delayed(AppConstants.cameraReconnectDelay, () {
      if (mounted) _reconnect();
    });
  }

  void _onBytes(List<int> chunk) {
    // MJPEG can be boundary-based OR raw JPEGs back-to-back.
    // We robustly find SOI(FFD8) ... EOI(FFD9).
    for (final b in chunk) {
      if (!_inFrame) {
        // wait for SOI
        _buf.add(b);
        final n = _buf.length;
        if (n >= 2 && _buf[n - 2] == _SOI0 && _buf[n - 1] == _SOI1) {
          // found SOI, start a fresh frame buffer from SOI
          _inFrame = true;
          _buf = [_SOI0, _SOI1];
        } else if (n > 2) {
          // keep buffer small while hunting SOI
          _buf = _buf.sublist(n - 2);
        }
      } else {
        _buf.add(b);
        final n = _buf.length;
        if (n >= 2 && _buf[n - 2] == _EOI0 && _buf[n - 1] == _EOI1) {
          // complete JPEG
          final frame = Uint8List.fromList(_buf);
          _buf = [];
          _inFrame = false;
          if (mounted) {
            setState(() {
              _currentFrame = frame;
              _status = 'Live';
              _hasError = false;
            });
          }
        }
      }
    }
  }

  // Method to refresh camera connection with new settings
  void refreshConnection() {
    _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(20);
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        height: widget.height,
        width: double.infinity,
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_currentFrame != null)
              Image.memory(
                _currentFrame!,
                gaplessPlayback: true,
                fit: BoxFit.cover,
              )
            else
              _placeholder(),
            Positioned(
              left: 12,
              top: 12,
              child: _livePill(_connecting ? 'CONNECTING' : 'LIVE'),
            ),
            if (_hasError || _currentFrame == null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _status,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_hasError) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Tap to retry connection',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            // Tap to retry when there's an error
            if (_hasError)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _initializeCamera(),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.videocam, color: Colors.white54, size: 48),
        SizedBox(height: 8),
        Text('Live Camera Feed', style: TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _livePill(String text) {
    final isConnecting = text == 'CONNECTING';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isConnecting ? Colors.orange : Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}