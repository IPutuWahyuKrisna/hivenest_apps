import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum SnackbarType { success, error, warning, info }

/// Notifikasi terpusat untuk seluruh app, supaya style pesan error/sukses
/// konsisten dan tidak lagi ditulis manual lewat ScaffoldMessenger di tiap page.
class SnackbarHelper {
  static void show(
    BuildContext context, {
    required String message,
    required SnackbarType type,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final config = _getConfig(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: config.iconColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(config.icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: config.backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: config.iconColor.withValues(alpha: 0.3)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: duration,
        action: action,
        elevation: 4,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.success);
  }

  static void showError(BuildContext context, String message) {
    show(
      context,
      message: message,
      type: SnackbarType.error,
      duration: const Duration(seconds: 5),
    );
  }

  static void showWarning(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.warning);
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.info);
  }

  static _SnackbarConfig _getConfig(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return _SnackbarConfig(
          icon: Icons.check_circle_rounded,
          backgroundColor: AppColors.statusGreenBg,
          iconColor: AppColors.statusGreenText,
        );
      case SnackbarType.error:
        return _SnackbarConfig(
          icon: Icons.error_rounded,
          backgroundColor: AppColors.statusRedBg,
          iconColor: AppColors.statusRedText,
        );
      case SnackbarType.warning:
        return _SnackbarConfig(
          icon: Icons.warning_rounded,
          backgroundColor: AppColors.statusAmberBg,
          iconColor: AppColors.statusAmberText,
        );
      case SnackbarType.info:
        return _SnackbarConfig(
          icon: Icons.info_rounded,
          backgroundColor: AppColors.statusBlueBg,
          iconColor: AppColors.statusBlueText,
        );
    }
  }
}

class _SnackbarConfig {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  _SnackbarConfig({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });
}
