import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:magic_life_wheel/dialog_service.dart';

class WarningDialog extends StatefulWidget {
  const WarningDialog({
    super.key,
    required this.message,
    this.subtitle,
    this.confirmMessage = "Confirm",
    this.secondaryMessage,
    this.confirmButtonColor = Colors.red,
    this.confirmButtonForegroundColor = Colors.white,
  });

  final String message;
  final String? subtitle;
  final String confirmMessage;
  final String? secondaryMessage;
  final Color confirmButtonColor;
  final Color confirmButtonForegroundColor;

  @override
  State<WarningDialog> createState() => _WarningDialogState();
}

class _WarningDialogState extends State<WarningDialog> {
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
      title: Column(
        children: [
          Text(widget.message),
          if (widget.subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                widget.subtitle!,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          const Gap(16.0),
          Row(
            children: [
              if (widget.secondaryMessage != null)
                TextButton(
                  child: Text(widget.secondaryMessage!),
                  onPressed: () async {
                    Navigator.of(context).pop(-1);
                  },
                ),
              const Spacer(),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(0);
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: FilledButton(
                  style: ButtonStyle(
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    backgroundColor: WidgetStatePropertyAll(widget.confirmButtonColor),
                    foregroundColor: WidgetStatePropertyAll(widget.confirmButtonForegroundColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(1);
                  },
                  child: Text(widget.confirmMessage),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
