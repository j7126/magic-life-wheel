import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:magic_life_wheel/datamodel/player.dart';
import 'package:magic_life_wheel/dialog_service.dart';
import 'package:magic_life_wheel/life_counter_page/dialogs/damage_history_dialog.dart';
import 'package:magic_life_wheel/static_service.dart';
import 'package:magic_life_wheel/life_counter_page/card_image/background_widget.dart';
import 'package:magic_life_wheel/life_counter_page/dialogs/edit_player/edit_background_dialog.dart';

class EditPlayerDialog extends StatefulWidget {
  const EditPlayerDialog({
    super.key,
    required this.player,
    required this.players,
  });

  final Player player;
  final List<Player> players;

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
    DialogService.register(context);
    _nameController = TextEditingController(text: widget.player.name);
    _lifeController = TextEditingController(text: widget.player.life.toString());
    super.initState();
  }

  @override
  void dispose() {
    DialogService.deregister(context);
    _nameController.dispose();
    _lifeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var onBackgroundShadow = widget.player.background.hasBackground
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
      titlePadding: const EdgeInsets.only(top: 12.0, left: 24.0, right: 16.0),
      contentPadding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 32.0, top: 8.0),
      title: Row(
        children: [
          const Text("Edit Player"),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (BuildContext context) => DamageHistoryDialog(
                  player: widget.player,
                  players: widget.players,
                ),
              );
            },
          ),
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
            if ((widget.player.dead && !widget.player.deadByCommander) || !widget.player.enableDead)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.player.enableDead = !widget.player.enableDead;
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Loose on life",
                                  style: Theme.of(context).textTheme.titleMedium,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text(
                                  "Loose the game on 0 or less life",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Gap(4.0),
                          Switch(
                            value: widget.player.enableDead,
                            onChanged: (bool value) {
                              setState(() {
                                widget.player.enableDead = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
            const Gap(16),
            TextField(
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
            const Gap(16),
            GestureDetector(
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
                            BackgroundWidget(
                              background: widget.player.background,
                              forceShowNoImageIcon: true,
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
          ],
        ),
      ),
    );
  }
}
