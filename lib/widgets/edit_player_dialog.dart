import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic_life_wheel/datamodel/player.dart';
import 'package:magic_life_wheel/service/static_service.dart';
import 'package:magic_life_wheel/widgets/card_image.dart';
import 'package:magic_life_wheel/widgets/edit_background_dialog.dart';

class EditPlayerDialog extends StatefulWidget {
  const EditPlayerDialog({super.key, required this.player});

  final Player player;

  @override
  State<EditPlayerDialog> createState() => _EditPlayerDialogState();
}

class _EditPlayerDialogState extends State<EditPlayerDialog> {
  late TextEditingController _nameController;
  late TextEditingController _lifeController;

  void editBackground() async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => EditBackgroundDialog(player: widget.player),
    );
    setState(() {});
  }

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.player.name);
    _lifeController = TextEditingController(text: widget.player.life.toString());
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lifeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var onBackgroundShadow = widget.player.card != null
        ? const [
            Shadow(
              offset: Offset(0, 0),
              blurRadius: 2.0,
              color: Color.fromARGB(100, 0, 0, 0),
            ),
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 1.0,
              color: Colors.black,
            ),
            Shadow(
              offset: Offset(2, 2),
              blurRadius: 4.0,
              color: Colors.black,
            ),
          ]
        : null;

    return AlertDialog(
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
              controller: _nameController,
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
                controller: _lifeController,
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
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: GestureDetector(
                onTap: Service.dataLoader.loaded && Service.dataLoader.allSetCards != null ? editBackground : null,
                child: Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    width: 250,
                    height: 190,
                    child: !Service.dataLoader.loaded || Service.dataLoader.allSetCards == null
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Stack(
                            children: [
                              CardImage(
                                key: Key(widget.player.card?.uuid ?? ""),
                                cardSet: widget.player.card,
                                iconPadding: const EdgeInsets.only(top: 22.0),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                child: Row(
                                  children: [
                                    Text(
                                      "Background",
                                      style: TextStyle(
                                        fontSize: 18,
                                        shadows: onBackgroundShadow,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.edit_outlined,
                                      shadows: onBackgroundShadow,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
