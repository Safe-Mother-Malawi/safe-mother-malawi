import 'package:flutter/material.dart';
import 'package:safe_mother_malawi/services/notification_sound_service.dart';

/// Notification popup widget with sound playback
/// Displays notifications with animation and auto-dismiss
class NotificationPopup extends StatefulWidget {
  final String title;
  final String message;
  final String? soundType;
  final Duration displayDuration;
  final VoidCallback? onDismiss;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double volume;

  const NotificationPopup({
    Key? key,
    required this.title,
    required this.message,
    this.soundType = 'default',
    this.displayDuration = const Duration(seconds: 5),
    this.onDismiss,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.volume = 1.0,
  }) : super(key: key);

  @override
  State<NotificationPopup> createState() => _NotificationPopupState();
}

class _NotificationPopupState extends State<NotificationPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late NotificationSoundService _soundService;
  late Future<void> _soundPlayFuture;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Slide animation (from top)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    // Initialize sound service
    _soundService = NotificationSoundService();

    // Play sound and start animations
    _soundPlayFuture = _initializeAndPlaySound();

    // Start slide-in animation
    _animationController.forward();

    // Auto-dismiss after display duration
    Future.delayed(widget.displayDuration, _dismissNotification);
  }

  /// Initialize sound service and play notification sound
  Future<void> _initializeAndPlaySound() async {
    try {
      await _soundService.initialize();
      await _soundService.playNotificationSound(
        soundType: widget.soundType ?? 'default',
        volume: widget.volume,
      );
      debugPrint('✓ Notification sound played');
    } catch (e) {
      debugPrint('❌ Error playing notification sound: $e');
    }
  }

  /// Dismiss notification with animation
  void _dismissNotification() {
    if (mounted) {
      _animationController.reverse().then((_) {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onDismiss?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: widget.backgroundColor ?? Colors.blue.shade900,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.shade700,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Icon
                    if (widget.icon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Icon(
                          widget.icon,
                          color: widget.textColor ?? Colors.white,
                          size: 32,
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Icon(
                          Icons.notifications_active,
                          color: widget.textColor ?? Colors.white,
                          size: 32,
                        ),
                      ),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            widget.title,
                            style: TextStyle(
                              color: widget.textColor ?? Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Message
                          Text(
                            widget.message,
                            style: TextStyle(
                              color: (widget.textColor ?? Colors.white)
                                  .withOpacity(0.9),
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Close button
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: GestureDetector(
                        onTap: _dismissNotification,
                        child: Icon(
                          Icons.close,
                          color: widget.textColor ?? Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper class to show notification popups
class NotificationPopupHelper {
  /// Show notification popup at the top of the screen
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String soundType = 'default',
    Duration displayDuration = const Duration(seconds: 5),
    VoidCallback? onDismiss,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    double volume = 1.0,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.topCenter,
          child: NotificationPopup(
            title: title,
            message: message,
            soundType: soundType,
            displayDuration: displayDuration,
            onDismiss: onDismiss,
            backgroundColor: backgroundColor,
            textColor: textColor,
            icon: icon,
            volume: volume,
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }

  /// Show success notification
  static void showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    Duration displayDuration = const Duration(seconds: 4),
    VoidCallback? onDismiss,
  }) {
    show(
      context,
      title: title,
      message: message,
      soundType: 'success',
      displayDuration: displayDuration,
      onDismiss: onDismiss,
      backgroundColor: Colors.green.shade700,
      textColor: Colors.white,
      icon: Icons.check_circle,
      volume: 0.6,
    );
  }

  /// Show error notification
  static void showError(
    BuildContext context, {
    required String title,
    required String message,
    Duration displayDuration = const Duration(seconds: 5),
    VoidCallback? onDismiss,
  }) {
    show(
      context,
      title: title,
      message: message,
      soundType: 'error',
      displayDuration: displayDuration,
      onDismiss: onDismiss,
      backgroundColor: Colors.red.shade700,
      textColor: Colors.white,
      icon: Icons.error,
      volume: 0.8,
    );
  }

  /// Show warning notification
  static void showWarning(
    BuildContext context, {
    required String title,
    required String message,
    Duration displayDuration = const Duration(seconds: 5),
    VoidCallback? onDismiss,
  }) {
    show(
      context,
      title: title,
      message: message,
      soundType: 'warning',
      displayDuration: displayDuration,
      onDismiss: onDismiss,
      backgroundColor: Colors.orange.shade700,
      textColor: Colors.white,
      icon: Icons.warning,
      volume: 0.7,
    );
  }

  /// Show alert notification
  static void showAlert(
    BuildContext context, {
    required String title,
    required String message,
    Duration displayDuration = const Duration(seconds: 6),
    VoidCallback? onDismiss,
  }) {
    show(
      context,
      title: title,
      message: message,
      soundType: 'alert',
      displayDuration: displayDuration,
      onDismiss: onDismiss,
      backgroundColor: Colors.red.shade900,
      textColor: Colors.white,
      icon: Icons.notifications_active,
      volume: 1.0,
    );
  }

  /// Show info notification
  static void showInfo(
    BuildContext context, {
    required String title,
    required String message,
    Duration displayDuration = const Duration(seconds: 4),
    VoidCallback? onDismiss,
  }) {
    show(
      context,
      title: title,
      message: message,
      soundType: 'reminder',
      displayDuration: displayDuration,
      onDismiss: onDismiss,
      backgroundColor: Colors.blue.shade700,
      textColor: Colors.white,
      icon: Icons.info,
      volume: 0.6,
    );
  }
}
