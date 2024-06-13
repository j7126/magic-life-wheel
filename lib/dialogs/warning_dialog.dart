import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class WarningDialog extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Text(message),
          const Gap(16.0),
          Row(
            children: [
              if (secondaryMessage != null)
                TextButton(
                  child: Text(secondaryMessage!),
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
                  child: Text(confirmMessage),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
