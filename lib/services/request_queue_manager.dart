import 'dart:async';
import 'package:flutter/foundation.dart';

/// Represents a queued API request
class QueuedRequest {
  final String id;
  final Future<dynamic> Function() execute;
  final Completer<dynamic> completer;
  int retryCount = 0;
  static const int maxRetries = 3;

  QueuedRequest({
    required this.id,
    required this.execute,
  }) : completer = Completer<dynamic>();

  Future<dynamic> get future => completer.future;
}

/// Manages API request queuing with exponential backoff and concurrency control
class RequestQueueManager {
  static final RequestQueueManager _instance = RequestQueueManager._();
  factory RequestQueueManager() => _instance;
  RequestQueueManager._();

  final Queue<QueuedRequest> _queue = Queue();
  int _activeRequests = 0;
  static const int _maxConcurrentRequests = 10; // Allow up to 10 concurrent requests
  static const int _baseDelayMs = 100; // Base delay between requests
  Timer? _processTimer;
  bool _isProcessing = false;

  int get queueLength => _queue.length;
  int get activeRequests => _activeRequests;
  bool get isProcessing => _isProcessing;

  /// Queue a request for execution
  Future<dynamic> queue(String id, Future<dynamic> Function() execute) {
    final request = QueuedRequest(id: id, execute: execute);
    _queue.add(request);
    _startProcessing();
    return request.future;
  }

  /// Start processing the queue
  void _startProcessing() {
    if (_isProcessing) return;
    _isProcessing = true;

    _processTimer = Timer.periodic(Duration(milliseconds: _baseDelayMs), (_) {
      _processNext();
    });
  }

  /// Process next request in queue
  Future<void> _processNext() async {
    // Stop if no more requests or max concurrent reached
    if (_queue.isEmpty || _activeRequests >= _maxConcurrentRequests) {
      if (_queue.isEmpty && _activeRequests == 0) {
        _stopProcessing();
      }
      return;
    }

    final request = _queue.removeFirst();
    _activeRequests++;

    try {
      final result = await request.execute();
      request.completer.complete(result);
      debugPrint('✅ Request ${request.id} completed successfully');
    } catch (e) {
      // Retry logic with exponential backoff
      if (request.retryCount < QueuedRequest.maxRetries) {
        request.retryCount++;
        final delayMs = _baseDelayMs * (1 << request.retryCount); // Exponential backoff
        debugPrint('🔄 Retrying request ${request.id} (attempt ${request.retryCount}/${QueuedRequest.maxRetries}) after ${delayMs}ms');
        
        // Re-queue with delay
        await Future.delayed(Duration(milliseconds: delayMs));
        _queue.add(request);
      } else {
        debugPrint('❌ Request ${request.id} failed after ${QueuedRequest.maxRetries} retries: $e');
        request.completer.completeError(e);
      }
    } finally {
      _activeRequests--;
    }
  }

  /// Stop processing
  void _stopProcessing() {
    _processTimer?.cancel();
    _processTimer = null;
    _isProcessing = false;
    debugPrint('✅ Request queue processing stopped');
  }

  /// Clear all pending requests
  void clear() {
    _queue.clear();
    _stopProcessing();
    debugPrint('🗑️ Request queue cleared');
  }

  /// Get queue statistics
  Map<String, dynamic> getStats() => {
    'queueLength': _queue.length,
    'activeRequests': _activeRequests,
    'isProcessing': _isProcessing,
    'maxConcurrent': _maxConcurrentRequests,
  };
}
