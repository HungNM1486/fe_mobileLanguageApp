import 'package:flutter/material.dart';

class ToastHelper {
  static void showSuccess(BuildContext context, String message) {
    _showToast(context, message, Colors.green, Icons.check_circle);
  }

  static void showError(BuildContext context, String message) {
    _showToast(context, message, Colors.red, Icons.error);
  }

  static void showInfo(BuildContext context, String message) {
    _showToast(context, message, Colors.blue, Icons.info);
  }

  static void _showToast(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData iconData,
  ) {
    final overlay = Overlay.of(context);
    final size = MediaQuery.of(context).size;

    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: size.height * 0.1,
        width: size.width,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(iconData, color: Colors.white),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}
