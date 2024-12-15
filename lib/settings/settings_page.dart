import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:keyrune_icons_flutter/keyrune_icons_flutter.dart';
import 'package:magic_life_wheel/static_service.dart';
import 'package:mana_icons_flutter/mana_icons_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  final TextEditingController startingLifeController = TextEditingController();
  final int initialLife = Service.settingsService.pref_startingLife;
  final List<int> options = [20, 30, 40, 60];

  late final AnimationController _advancedAnimationController = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  late final Animation<double> _advancedAnimation = CurvedAnimation(
    parent: _advancedAnimationController,
    curve: Curves.fastOutSlowIn,
  );

  bool _showAdvanced = false;
  bool get showAdvanced => _showAdvanced;
  set showAdvanced(bool value) {
    _showAdvanced = value;
    if (value) {
      _advancedAnimationController.forward();
    } else {
      _advancedAnimationController.reverse();
    }
  }

  late final AnimationController _commanderAnimationController = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
    value: enableCommander ? 1.0 : 0.0,
  );
  late final Animation<double> _commanderAnimation = CurvedAnimation(
    parent: _commanderAnimationController,
    curve: Curves.fastOutSlowIn,
  );

  bool get enableCommander => Service.settingsService.pref_enableCommanderDamage;
  set enableCommander(bool value) {
    Service.settingsService.pref_enableCommanderDamage = value;
    if (value) {
      _commanderAnimationController.forward();
    } else {
      _commanderAnimationController.reverse();
    }
  }

  void onStartingLifeTextChanged() {
    var val = int.tryParse(startingLifeController.text);
    if (val != null) {
      Service.settingsService.pref_startingLife = val;
    }
  }

  @override
  void initState() {
    if (!options.contains(initialLife)) {
      options.add(initialLife);
      options.sort();
    }
    startingLifeController.addListener(onStartingLifeTextChanged);
    super.initState();
  }

  @override
  void dispose() {
    onStartingLifeTextChanged();
    _advancedAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 4,
        shadowColor: Theme.of(context).colorScheme.shadow,
        title: const Text("Settings"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.favorite_outline,
                              size: 32,
                              color: Color.fromARGB(255, 127, 127, 127),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Starting Life",
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: const Color.fromARGB(255, 229, 229, 229),
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      "The starting life total for players.",
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            color: const Color.fromARGB(255, 229, 229, 229),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DropdownMenu<int>(
                              initialSelection: initialLife,
                              controller: startingLifeController,
                              enableFilter: false,
                              requestFocusOnTap: true,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              inputDecorationTheme: const InputDecorationTheme(
                                filled: false,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 2.0),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 24,
                              ),
                              width: 94,
                              dropdownMenuEntries: options
                                  .map(
                                    (e) => DropdownMenuEntry<int>(
                                      value: e,
                                      label: e.toString(),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            Service.settingsService.pref_enablePlanechase =
                                !Service.settingsService.pref_enablePlanechase;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                          child: Row(
                            children: [
                              const Icon(
                                ManaIcons.ms_planeswalker,
                                size: 32,
                                color: Color.fromARGB(255, 127, 127, 127),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Planechase",
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              color: const Color.fromARGB(255, 229, 229, 229),
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        "Enable Planechase",
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              color: const Color.fromARGB(255, 229, 229, 229),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Switch(
                                value: Service.settingsService.pref_enablePlanechase,
                                onChanged: (bool value) {
                                  setState(() {
                                    Service.settingsService.pref_enablePlanechase = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            enableCommander = !enableCommander;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 12.0, bottom: 0.0),
                          child: Row(
                            children: [
                              const Icon(
                                KeyruneIcons.ss_cmd,
                                size: 32,
                                color: Color.fromARGB(255, 127, 127, 127),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Commander",
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              color: const Color.fromARGB(255, 229, 229, 229),
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        "Commander damage tracking.",
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              color: const Color.fromARGB(255, 229, 229, 229),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Switch(
                                value: enableCommander,
                                onChanged: (bool value) {
                                  setState(() {
                                    enableCommander = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizeTransition(
                        sizeFactor: _commanderAnimation,
                        axis: Axis.vertical,
                        axisAlignment: -1,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  Service.settingsService.pref_asymmetricalCommanderDamageButtons =
                                      !Service.settingsService.pref_asymmetricalCommanderDamageButtons;
                                });
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 32,
                                      height: 32,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Text(
                                          "Larger + button.",
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                color: const Color.fromARGB(255, 229, 229, 229),
                                              ),
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: Service.settingsService.pref_asymmetricalCommanderDamageButtons,
                                      onChanged: (bool value) {
                                        setState(() {
                                          Service.settingsService.pref_asymmetricalCommanderDamageButtons = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  Service.settingsService.pref_commanderDamageButtonsFacePlayer =
                                      !Service.settingsService.pref_commanderDamageButtonsFacePlayer;
                                });
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 32,
                                      height: 32,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Text(
                                          "Buttons face player",
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                color: const Color.fromARGB(255, 229, 229, 229),
                                              ),
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: Service.settingsService.pref_commanderDamageButtonsFacePlayer,
                                      onChanged: (bool value) {
                                        setState(() {
                                          Service.settingsService.pref_commanderDamageButtonsFacePlayer = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  Service.settingsService.pref_commanderDamageMiniGrid =
                                      !Service.settingsService.pref_commanderDamageMiniGrid;
                                });
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 32,
                                      height: 32,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Text(
                                          "Mini Grid",
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                color: const Color.fromARGB(255, 229, 229, 229),
                                              ),
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: Service.settingsService.pref_commanderDamageMiniGrid,
                                      onChanged: (bool value) {
                                        setState(() {
                                          Service.settingsService.pref_commanderDamageMiniGrid = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(12.0),
                    ],
                  ),
                ),
              ),
              const Gap(12.0),
              Card(
                margin: EdgeInsets.zero,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  padding: showAdvanced ? const EdgeInsets.symmetric(vertical: 8.0) : EdgeInsets.zero,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showAdvanced = !showAdvanced;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                          child: Row(
                            children: [
                              AnimatedRotation(
                                duration: const Duration(milliseconds: 200),
                                turns: showAdvanced ? 0.5 : 0,
                                child: Transform.scale(
                                  scale: 1.2,
                                  child: const Icon(
                                    Icons.expand_more,
                                    size: 32,
                                    color: Color.fromARGB(255, 178, 178, 178),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Advanced settings",
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              color: const Color.fromARGB(255, 229, 229, 229),
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        showAdvanced ? "Hide" : "Show More",
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              color: const Color.fromARGB(255, 229, 229, 229),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizeTransition(
                        sizeFactor: _advancedAnimation,
                        axis: Axis.vertical,
                        axisAlignment: -1,
                        child: Column(
                          children: [
                            const Divider(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  Service.settingsService.pref_getScryfallImages =
                                      !Service.settingsService.pref_getScryfallImages;
                                });
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.image_outlined,
                                      size: 32,
                                      color: Color.fromARGB(255, 127, 127, 127),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Card images",
                                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                    color: const Color.fromARGB(255, 229, 229, 229),
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            Text(
                                              "Fetch card images from scryfall.",
                                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                    color: const Color.fromARGB(255, 229, 229, 229),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: Service.settingsService.pref_getScryfallImages,
                                      onChanged: (bool value) {
                                        setState(() {
                                          Service.settingsService.pref_getScryfallImages = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  Service.settingsService.pref_enableSaveState =
                                      !Service.settingsService.pref_enableSaveState;
                                });
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.save_outlined,
                                      size: 32,
                                      color: Color.fromARGB(255, 127, 127, 127),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Persistence",
                                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                    color: const Color.fromARGB(255, 229, 229, 229),
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            Text(
                                              "Save the state of players.",
                                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                    color: const Color.fromARGB(255, 229, 229, 229),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: Service.settingsService.pref_enableSaveState,
                                      onChanged: (bool value) {
                                        setState(() {
                                          Service.settingsService.pref_enableSaveState = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  Service.settingsService.pref_showChangingLife =
                                      !Service.settingsService.pref_showChangingLife;
                                });
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.history_outlined,
                                      size: 32,
                                      color: Color.fromARGB(255, 127, 127, 127),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Show Changed Life",
                                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                    color: const Color.fromARGB(255, 229, 229, 229),
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            Text(
                                              "Show the changed life for a short time.",
                                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                    color: const Color.fromARGB(255, 229, 229, 229),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: Service.settingsService.pref_showChangingLife,
                                      onChanged: (bool value) {
                                        setState(() {
                                          Service.settingsService.pref_showChangingLife = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  Service.settingsService.pref_maximiseFontSize =
                                      !Service.settingsService.pref_maximiseFontSize;
                                });
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.format_size,
                                      size: 32,
                                      color: Color.fromARGB(255, 127, 127, 127),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Maximise Font Size",
                                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                    color: const Color.fromARGB(255, 229, 229, 229),
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            Text(
                                              "Maximises the font size of the life counters. The font size of all the counters may not be the same.",
                                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                    color: const Color.fromARGB(255, 229, 229, 229),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: Service.settingsService.pref_maximiseFontSize,
                                      onChanged: (bool value) {
                                        setState(() {
                                          Service.settingsService.pref_maximiseFontSize = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
