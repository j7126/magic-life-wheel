import 'package:flutter/material.dart';

class DialogService {
  static final List<BuildContext> _dialogContexts = [];

  static void register(BuildContext context) {
    if (!context.mounted) return;
    _dialogContexts.add(context);
  }

  static void deregister(BuildContext context) {
    _dialogContexts.remove(context);
  }

  static Future closeAllDialogs() async {
    if (_dialogContexts.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 1000));
      for (var maxTries = 100; _dialogContexts.isNotEmpty && maxTries > 0; maxTries--) {
        var context = _dialogContexts[0];
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        _dialogContexts.remove(context);
      }
    }
  }
}
