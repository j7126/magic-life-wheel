import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic_life_wheel/datamodel/player.dart';

class Counter extends StatefulWidget {
  const Counter({super.key, required this.player, required this.i});

  final int i;
  final Player player;

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  void editPlayerBackground() {}

  void editPlayer() {
    TextEditingController nameController = TextEditingController(text: widget.player.name);
    TextEditingController lifeController = TextEditingController(text: widget.player.life.toString());
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        titlePadding: const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0),
        contentPadding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 32.0, top: 8.0),
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
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Player Name',
                  isDense: true,
                ),
                onChanged: (text) {
                  setState(() {
                    widget.player.name = text;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: lifeController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Life',
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (text) {
                    setState(() {
                      try {
                        widget.player.life = int.parse(text);
                      } catch (e) {}
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var playerNameBtn = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: editPlayer,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(widget.player.name.isEmpty ? "Player ${widget.i + 1}" : widget.player.name),
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
