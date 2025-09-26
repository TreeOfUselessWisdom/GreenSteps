import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension NavigationHelper on BuildContext {
  /// Push a new screen onto the stack
  void navigateTo(String path) {
    push(path); // uses go_router push
  }

  /// Replace the current screen (clear stack)
  void replaceWith(String path) {
    go(path); // uses go_router go
  }

  /// Navigate back if possible
  void navigateBack() {
    if (Navigator.of(this).canPop()) {
      Navigator.of(this).pop();
    }
  }
}
