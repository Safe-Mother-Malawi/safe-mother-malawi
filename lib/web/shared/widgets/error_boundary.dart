import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';

/// Wraps a child widget and catches any errors during build,
/// showing a friendly error card instead of crashing the dashboard.
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final String? context;

  const ErrorBoundary({super.key, required this.child, this.context});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _ErrorCard(
        error: _error!,
        context: widget.context,
        onRetry: () => setState(() => _error = null),
      );
    }

    return _CatchErrors(
      onError: (e) => setState(() => _error = e),
      child: widget.child,
    );
  }
}

class _CatchErrors extends StatelessWidget {
  final Widget child;
  final void Function(Object) onError;

  const _CatchErrors({required this.child, required this.onError});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (details) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onError(details.exception);
      });
      return const SizedBox.shrink();
    };
    return child;
  }
}

class _ErrorCard extends StatelessWidget {
  final Object error;
  final String? context;
  final VoidCallback onRetry;

  const _ErrorCard({required this.error, this.context, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.criticalBg),
          boxShadow: [BoxShadow(color: AppColors.criticalText.withOpacity(0.08), blurRadius: 24)],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: AppColors.criticalBg, shape: BoxShape.circle),
            child: const Icon(Icons.error_outline_rounded, color: AppColors.criticalText, size: 28),
          ),
          const SizedBox(height: 16),
          Text('Something went wrong',
              style: GoogleFonts.publicSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.headings)),
          const SizedBox(height: 8),
          Text(
            'An unexpected error occurred${this.context != null ? ' in ${this.context}' : ''}. '
            'Your data is safe — this is a display issue only.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ]),
      ),
    );
  }
}
