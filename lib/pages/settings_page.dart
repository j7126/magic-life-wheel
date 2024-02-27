import 'package:flutter/material.dart';
import 'package:keyrune_icons_flutter/keyrune_icons_flutter.dart';
import 'package:magic_life_wheel/service/static_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController startingLifeController = TextEditingController(text: Service.settingsService.pref_startingLife.toString());

  void onStartingLifeTextChanged() {
    var val = int.tryParse(startingLifeController.text);
    if (val != null) {
      Service.settingsService.pref_startingLife = val;
    }
  }

  @override
  void initState() {
    startingLifeController.addListener(onStartingLifeTextChanged);

    super.initState();
  }

  @override
  void dispose() {
    onStartingLifeTextChanged();

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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Row(
                      children: [
                        const Opacity(
                          opacity: 0.5,
                          child: Icon(
                            Icons.favorite_outline,
                            size: 32,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Opacity(
                              opacity: 0.9,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Starting Life",
                                    style: Theme.of(context).textTheme.titleLarge,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    "The starting life total for players.",
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        DropdownMenu<int>(
                          controller: startingLifeController,
                          enableFilter: false,
                          requestFocusOnTap: true,
                          inputDecorationTheme: const InputDecorationTheme(
                            filled: false,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 2.0),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 24,
                          ),
                          width: 94,
                          onSelected: (int? val) {
                            setState(() {
                              if (val != null) {
                                Service.settingsService.pref_startingLife = val;
                              }
                            });
                          },
                          dropdownMenuEntries: [20, 30, 40, 60]
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      Service.settingsService.pref_getScryfallImages = !Service.settingsService.pref_getScryfallImages;
                    });
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Row(
                        children: [
                          const Opacity(
                            opacity: 0.5,
                            child: Icon(
                              Icons.image_outlined,
                              size: 32,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Opacity(
                                opacity: 0.9,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Card images",
                                      style: Theme.of(context).textTheme.titleLarge,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      "Fetch card images from scryfall.",
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                  ],
                                ),
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      Service.settingsService.pref_enableCommanderDamage = !Service.settingsService.pref_enableCommanderDamage;
                    });
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Row(
                        children: [
                          const Opacity(
                            opacity: 0.5,
                            child: Icon(
                              KeyruneIcons.ss_cmd,
                              size: 32,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Opacity(
                                opacity: 0.9,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Commander",
                                      style: Theme.of(context).textTheme.titleLarge,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      "Commander damage tracking.",
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Switch(
                            value: Service.settingsService.pref_enableCommanderDamage,
                            onChanged: (bool value) {
                              setState(() {
                                Service.settingsService.pref_enableCommanderDamage = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      Service.settingsService.pref_enableSaveState = !Service.settingsService.pref_enableSaveState;
                    });
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Row(
                        children: [
                          const Opacity(
                            opacity: 0.5,
                            child: Icon(
                              Icons.save_outlined,
                              size: 32,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Opacity(
                                opacity: 0.9,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Persistence",
                                      style: Theme.of(context).textTheme.titleLarge,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      "Save the state of players.",
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                  ],
                                ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
