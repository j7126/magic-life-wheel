import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SetColorsDialog extends StatefulWidget {
  const SetColorsDialog({
    super.key,
    required this.colors,
  });

  final List<Color>? colors;

  @override
  State<SetColorsDialog> createState() => _SetColorsDialogState();
}

class _SetColorsDialogState extends State<SetColorsDialog> {
  late List<Color> colors;

  static const List<List<(Color, bool)>> colorOptions = [
    [
      (Color.fromARGB(255, 233, 227, 176), true),
      (Color.fromARGB(255, 141, 186, 208), false),
      (Color.fromARGB(255, 154, 141, 137), false),
      (Color.fromARGB(255, 221, 128, 101), false),
      (Color.fromARGB(255, 127, 175, 145), false),
    ],
    [
      (Colors.white, true),
      (Colors.blue, false),
      (Color.fromARGB(255, 10, 10, 10), false),
      (Colors.red, false),
      (Colors.green, false),
    ],
    [
      (Color.fromARGB(255, 32, 28, 20), false),
      (Color.fromARGB(255, 5, 24, 33), false),
      (Color.fromARGB(255, 18, 11, 13), false),
      (Color.fromARGB(255, 31, 0, 0), false),
      (Color.fromARGB(255, 0, 21, 10), false),
    ],
  ];

  @override
  void initState() {
    colors = widget.colors ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    colorButton(Color color, double constrainedWidth, bool darkIcon) {
      var size = constrainedWidth / 5;
      var checked = colors.any((x) => x.value == color.value);
      var foregroundColor = darkIcon ? Colors.black : Colors.white;

      return SizedBox(
        width: size,
        height: size,
        child: Padding(
          padding: EdgeInsets.all(size / 8),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (!checked) {
                  colors.add(color);
                } else {
                  colors.removeWhere((x) => x.value == color.value);
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size / 2),
                color: color,
                border: checked
                    ? Border.all(color: foregroundColor, width: 4.0, strokeAlign: BorderSide.strokeAlignOutside)
                    : null,
              ),
              child: checked
                  ? Icon(
                      Icons.check,
                      color: foregroundColor,
                      size: size / 2,
                    )
                  : null,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      var constrainedWidth = min(constraints.maxWidth, constraints.maxHeight) - 48 - 48 * 2;

      return AlertDialog(
        titlePadding: const EdgeInsets.only(top: 12.0, left: 16.0, right: 16.0),
        contentPadding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 32.0, top: 8.0),
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text("Customise Color"),
            ),
            const Spacer(),
            IconButton.outlined(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.of(context).pop(colors);
              },
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                key: ValueKey(colors.length),
                width: constrainedWidth / 3,
                height: constrainedWidth / 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  gradient: colors.length > 1
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: colors,
                        )
                      : null,
                  color: colors.length > 1 ? null : (colors.firstOrNull ?? const Color.fromARGB(255, 70, 73, 72)),
                ),
              ),
              const Gap(16.0),
              for (var row in colorOptions)
                Row(
                  children: row
                      .map((e) => colorButton(
                            e.$1,
                            constrainedWidth,
                            e.$2,
                          ))
                      .toList(),
                ),
            ],
          ),
        ),
      );
    });
  }
}
