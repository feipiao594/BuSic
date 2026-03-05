/// Tracks download speed and bytes for a single task.
///
/// Uses exponential moving average to smooth speed calculations.
class DownloadMetrics {
  int totalBytes = 0;
  int receivedBytes = 0;
  double speed = 0.0;
  int _prevReceived = 0;
  int _prevTime = 0;

  void update(int received, int total) {
    totalBytes = total;
    receivedBytes = received;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_prevTime == 0) {
      _prevTime = now;
      _prevReceived = received;
      return;
    }
    final elapsed = now - _prevTime;
    if (elapsed >= 500) {
      final instantSpeed = (received - _prevReceived) * 1000.0 / elapsed;
      speed = speed == 0 ? instantSpeed : 0.3 * instantSpeed + 0.7 * speed;
      _prevReceived = received;
      _prevTime = now;
    }
  }
}
