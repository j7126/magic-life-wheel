import 'package:flutter/material.dart';
import 'package:magic_life_wheel/dialog_service.dart';

class MessageDialog extends StatefulWidget {
  const MessageDialog({
    super.key,
    required this.title,
    this.message,
  });

  final String title;
  final String? message;

  @override
  State<MessageDialog> createState() => _MessageDialogState();
}

class _MessageDialogState extends State<MessageDialog> {
  @override
  void initState() {
    DialogService.register(context);
    super.initState();
  }

  @override
  void dispose() {
    DialogService.deregister(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: widget.message != null ? Text(widget.message!) : null,
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
