import 'package:flutter/material.dart';
import 'package:magic_life_wheel/player.dart';

class Counter extends StatefulWidget {
  const Counter({super.key, required this.player});

  final Player player;

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  void playerNameOnTap() {
    TextEditingController nameController = TextEditingController(text: widget.player.name);
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        titlePadding: const EdgeInsets.only(top: 12.0, left: 16.0, right: 16.0),
        contentPadding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
        title: Row(
          children: [
            const Text("Edit Player"),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Player Name',
            isDense: true,
          ),
          onChanged: (text) {
            setState(() {
              widget.player.name = text.isEmpty ? "Player ${widget.player.id + 1}" : text;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var playerNameBtn = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: playerNameOnTap,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(widget.player.name),
          ),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          color: const Color.fromARGB(50, 255, 255, 255),
        ),
        clipBehavior: Clip.antiAlias,
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Opacity(
                    opacity: 0,
                    child: playerNameBtn,
                  ),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          widget.player.life.toString(),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).colorScheme.onBackground,
                        ),
                        overlayColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).colorScheme.onBackground.withAlpha(30),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          widget.player.life--;
                        });
                      },
                      onLongPress: () {
                        setState(() {
                          widget.player.life -= 10;
                        });
                      },
                      child: const SizedBox(
                        height: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Icon(Icons.remove),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).colorScheme.onBackground,
                        ),
                        overlayColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).colorScheme.onBackground.withAlpha(30),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          widget.player.life++;
                        });
                      },
                      onLongPress: () {
                        setState(() {
                          widget.player.life += 10;
                        });
                      },
                      child: const SizedBox(
                        height: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              child: Center(
                child: Column(
                  children: [
                    playerNameBtn,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
