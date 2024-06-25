import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:magic_life_wheel/dialog_service.dart';

class WarningDialog extends StatefulWidget {
  const WarningDialog({
    super.key,
    required this.message,
    this.confirmMessage = "Confirm",
    this.secondaryMessage,
  });

  final String message;
  final String confirmMessage;
  final String? secondaryMessage;

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
                  style: const ButtonStyle(
                    padding: MaterialStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    backgroundColor: MaterialStatePropertyAll(Colors.red),
                    foregroundColor: MaterialStatePropertyAll(Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(1);
                  },
                  child: Text(widget.confirmMessage),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
