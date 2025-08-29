import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Change this to your ESP32-CAM IP (no http/port here)
const String camIp = '192.168.1.180/';

/// If you’re using the stock ESP32-CAM WebServer example, the MJPEG URL is:
///   http://<ip>:81/stream
const String streamUrl = 'http://$camIp:81/stream';

class LiveMjpegView extends StatefulWidget {
  final double height;
  final BorderRadius? borderRadius;

  const LiveMjpegView({
    Key? key,
    required this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<LiveMjpegView> createState() => _LiveMjpegViewState();
}

class _LiveMjpegViewState extends State<LiveMjpegView> {
  final _httpClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 6);

  StreamSubscription<List<int>>? _sub;
  Uint8List? _currentFrame;

  String _status = 'Connecting...';
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
    _connect();
  }

  @override
  void dispose() {
    _watchdog?.cancel();
    _sub?.cancel();
    _httpClient.close(force: true);
    super.dispose();
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
      _status = 'Connecting to $streamUrl ...';
      _buf.clear();
      _inFrame = false;
    });

    try {
      final uri = Uri.parse(streamUrl);
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
      _watchdog = Timer.periodic(const Duration(seconds: 5), (_) {
        if (_currentFrame == null) {
          _setStatus('No frames yet… retrying', error: true);
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
    Future.delayed(const Duration(seconds: 2), () {
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
              child: _livePill(_connecting ? 'LIVE (connecting)' : 'LIVE'),
            ),
            if (_hasError || _currentFrame == null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _status,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
