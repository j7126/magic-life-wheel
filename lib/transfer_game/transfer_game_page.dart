import 'dart:async';
import 'dart:math';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:gap/gap.dart';
import 'package:magic_life_wheel/datamodel/game.dart';
import 'package:magic_life_wheel/datamodel/player.dart';
import 'package:magic_life_wheel/dialogs/warning_dialog.dart';
import 'package:magic_life_wheel/static_service.dart';
import 'package:magic_life_wheel/transfer_game/transfer_url_service.dart';
import 'package:system_info2/system_info2.dart';
import 'package:tab_container/tab_container.dart';

class TransferGamePage extends StatefulWidget {
  const TransferGamePage({super.key, required this.game});

  final Game game;

  @override
  State<TransferGamePage> createState() => _TransferGamePageState();
}

class _TransferGamePageState extends State<TransferGamePage> with SingleTickerProviderStateMixin {
  bool firstRender = true;
  bool ready = false;
  bool importingData = false;
  bool cameraDenied = false;
  bool unknownCameraError = false;
  bool cameraReady = false;
  bool showLowPerformanceWarning = false;
  bool finalising = false;
  int split = 0;
  int splitCurrent = 0;
  Timer? splitTimer;
  late String data;
  List<String> splitData = [];
  Map<int, String> scannedSplit = {};
  int scannedNumSplit = 0;

  late final TabController _tabController;

  Future<bool> _showResetWarning(int numPlayers) async {
    return 1 ==
        await showDialog<int>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return WarningDialog(
              message: 'Do you want to import this $numPlayers player game? Your current game will be lost!',
              confirmMessage: 'Import',
            );
          },
        );
  }

  void buildQrData() async {
    data = await TransferUrlService.buildUrl(widget.game.players, widget.game.layoutId);
    setState(() {
      ready = true;
    });
  }

  void useUrl(String? url) async {
    setState(() {
      importingData = true;
    });

    if (url == null || !url.startsWith(Service.appBaseUrl)) {
      dataError();
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        importingData = false;
      });
      return;
    }

    var result = await TransferUrlService.parseUrl(url);
    if (result == null) {
      dataError();
    } else {
      useData(result.$1, result.$2);
    }

    if (mounted) {
      setState(() {
        importingData = false;
      });
    }
  }

  void useBase64Data(String? data) async {
    setState(() {
      importingData = true;
    });

    if (data == null) {
      dataError();
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        importingData = false;
      });
      return;
    }

    var result = await TransferUrlService.parseBase64Data(data);
    if (result == null) {
      dataError();
    } else {
      useData(result.$1, result.$2);
    }

    if (mounted) {
      setState(() {
        importingData = false;
      });
    }
  }

  void useData(List<Player> players, int layoutId) async {
    if (!widget.game.players.any((x) => !x.isReset) || await _showResetWarning(players.length)) {
      if (mounted) {
        setState(() {
          finalising = true;
        });
        // delay needed to prevent widget dispose race condition
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) {
          Navigator.of(context).pop((players, layoutId));
        }
      }
    }
  }

  void dataError() {
    if (mounted) {
      setState(() {
        scannedNumSplit = 0;
        scannedSplit.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The game data was not valid!'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 58.0),
        ),
      );
    }
  }

  void _split() async {
    if (split > 1) {
      setState(() {
        split = 1;
        splitCurrent = 0;
        splitTimer?.cancel();
        splitTimer = null;
      });
      return;
    }
    if (split > 0 ||
        1 ==
            await showDialog<int>(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return WarningDialog(
                  message: 'Split the QR code into multiple parts.',
                  subtitle:
                      "This can help if the QR code is too dense and you have trouble scanning it.\nNote: split codes must be scanned using the import tab, not another qr scanner app.",
                  confirmMessage: 'Split',
                  confirmButtonColor: Theme.of(context).colorScheme.primary,
                  confirmButtonForegroundColor: Theme.of(context).colorScheme.onPrimary,
                );
              },
            )) {
      setState(() {
        ready = false;
      });
      split = 8;
      splitData = await TransferUrlService.buildSplitStrings(widget.game.players, widget.game.layoutId, split);
      if (splitData.length < split) {
        split = splitData.length;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum split reached!'),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 58.0),
            ),
          );
        }
      }
      splitCurrent = 0;
      splitTimer ??= Timer.periodic(const Duration(milliseconds: 500), (timer) {
        setState(() {
          splitCurrent++;
          if (splitCurrent >= split) {
            splitCurrent = 0;
          }
        });
      });
      setState(() {
        ready = true;
      });
    }
  }

  void _onControllerCreated(_, Exception? error) {
    if (error != null) {
      if (error is CameraException) {
        if (error.code == "CameraAccessDenied") {
          if (mounted) {
            setState(() {
              cameraDenied = true;
            });
          }
          return;
        }
      }
      if (mounted) {
        setState(() {
          unknownCameraError = true;
        });
      }
      debugPrint(error.toString());
    } else {
      setState(() {
        cameraReady = true;
      });
    }
  }

  _onScanSuccess(Code? code) {
    if (code != null) {
      var text = code.text;
      if (text != null && text.length > 3 && text[0] == ',') {
        // handle multipart qr
        var i = int.tryParse(text[1]);
        var num = int.tryParse(text[2]);
        if (i != null && num != null && num > 1 && i >= 0 && i < num) {
          setState(() {
            var dataSegment = text.substring(3, text.length);
            if (num != scannedNumSplit || scannedSplit[i] != null && scannedSplit[i] != dataSegment) {
              scannedSplit.clear();
            }
            scannedNumSplit = num;
            scannedSplit[i] = dataSegment;
            if (scannedSplit.length == scannedNumSplit) {
              String? base64String = "";
              for (var i = 0; i < scannedNumSplit; i++) {
                var segment = scannedSplit[i];
                if (segment == null) {
                  base64String = null;
                  break;
                } else {
                  base64String = "$base64String$segment";
                }
              }
              useBase64Data(base64String);
              scannedNumSplit = 0;
              scannedSplit.clear();
            }
          });
        }
      } else {
        // handle single qr
        setState(() {
          scannedNumSplit = 0;
          scannedSplit.clear();
          useUrl(text);
        });
      }
    }
  }

  _onScanFailure(Code? code) {
    if (code?.error?.isNotEmpty == true) {
      unknownCameraError = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {
        if (_tabController.index != 1) {
          cameraReady = false;
        }
      });
    });
    if (!kIsWeb && SysInfo.getTotalPhysicalMemory() < 3500000000) {
      showLowPerformanceWarning = true;
    }
  }

  @override
  Future<void> dispose() async {
    splitTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (firstRender) {
      firstRender = false;
      buildQrData();
    }

    var hasCustomImage = widget.game.players.any((x) => x.background.customImage != null);

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var maxContentWidth = width - 68.0;
    var maxContentHeight = height - (width > height ? 278 : 352) - (hasCustomImage ? 56.0 : 0.0);
    var maxDimention = min(maxContentHeight, maxContentWidth);

    cameraError(String message, Function() retry) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.videocam_off,
                size: maxDimention / 3,
                color: Colors.black,
              ),
              SizedBox(
                width: maxDimention / 3 * 2,
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  width: maxDimention / 3 * 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          foregroundColor: WidgetStatePropertyAll(
                            HSLColor.fromColor(Theme.of(context).colorScheme.primary).withLightness(0.4).toColor(),
                          ),
                        ),
                        onPressed: retry,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.restart_alt),
                            Gap(4.0),
                            Text("Retry"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

    if (!Service.supportScanner ||
        _tabController.index != 1 ||
        (importingData) ||
        unknownCameraError ||
        cameraDenied ||
        showLowPerformanceWarning) {
      cameraReady = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transfer Game"),
      ),
      body: finalising
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0, top: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(width: double.infinity),
                    Card(
                      margin: const EdgeInsets.all(0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.info_outline),
                            const Gap(8.0),
                            Flexible(
                              fit: FlexFit.loose,
                              flex: 1,
                              child: Text(
                                "Transfer the current game to another device.",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (hasCustomImage)
                      const Card(
                        color: Colors.deepOrange,
                        margin: EdgeInsets.only(top: 12.0),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_amber_outlined),
                              Gap(8.0),
                              Flexible(
                                fit: FlexFit.loose,
                                flex: 1,
                                child: Text("Custom images will not be transfered."),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const Gap(12.0),
                    TabContainer(
                      controller: _tabController,
                      tabEdge: width > height ? TabEdge.left : TabEdge.top,
                      tabExtent: width > height ? 150 : 50,
                      borderRadius: BorderRadius.circular(10),
                      tabBorderRadius: BorderRadius.circular(10),
                      childPadding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 12.0),
                      selectedTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.black,
                          ),
                      unselectedTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                      colors: [
                        Colors.white,
                        HSLColor.fromColor(Theme.of(context).colorScheme.primary).withLightness(0.9).toColor(),
                      ],
                      tabs: [
                        SizedBox(
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Builder(builder: (context) {
                                return Icon(
                                  Icons.call_made,
                                  color: DefaultTextStyle.of(context).style.color,
                                );
                              }),
                              const Gap(8.0),
                              const Text('Send'),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Builder(builder: (context) {
                              return Icon(
                                Icons.call_received,
                                color: DefaultTextStyle.of(context).style.color,
                              );
                            }),
                            const Gap(8.0),
                            const Text('Import'),
                          ],
                        ),
                      ],
                      children: [
                        Column(
                          children: [
                            const SizedBox(width: double.infinity),
                            Text(
                              "Use the \"Import\" tab to scan this QR code on the other device.",
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
                            ),
                            const Gap(8.0),
                            SizedBox(
                              width: maxDimention,
                              height: maxDimention,
                              child: ready
                                  ? BarcodeWidget(
                                      barcode: Barcode.qrCode(),
                                      data: split <= 1 ? data : splitData[splitCurrent],
                                      backgroundColor: Colors.white,
                                      padding: EdgeInsets.zero,
                                    )
                                  : const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                            ),
                            const Gap(8.0),
                            Container(
                              child: ready
                                  ? SizedBox(
                                      height: 38,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          FilledButton(
                                            style: const ButtonStyle(
                                              padding: WidgetStatePropertyAll(
                                                EdgeInsets.symmetric(
                                                  vertical: 2.0,
                                                  horizontal: 20.0,
                                                ),
                                              ),
                                            ),
                                            onPressed: () {
                                              Clipboard.setData(
                                                ClipboardData(
                                                  text: data,
                                                ),
                                              );
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Game data copied to clipboard!'),
                                                  behavior: SnackBarBehavior.floating,
                                                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 58.0),
                                                ),
                                              );
                                            },
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.copy,
                                                  size: 20,
                                                ),
                                                Gap(8.0),
                                                Text("Copy"),
                                              ],
                                            ),
                                          ),
                                          const Gap(16.0),
                                          FilledButton(
                                            style: const ButtonStyle(
                                              padding: WidgetStatePropertyAll(
                                                EdgeInsets.symmetric(
                                                  vertical: 2.0,
                                                  horizontal: 20.0,
                                                ),
                                              ),
                                            ),
                                            onPressed: _split,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.grid_view_outlined,
                                                  size: 20,
                                                ),
                                                const Gap(8.0),
                                                split <= 1 ? const Text("Split") : const Text("Un-Split")
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: double.infinity),
                            Text(
                              "Scan the QR code displayed on the other device.",
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
                            ),
                            const Gap(8.0),
                            SizedBox(
                              width: maxDimention,
                              height: maxDimention,
                              child: Service.supportScanner
                                  ? _tabController.index == 1
                                      ? showLowPerformanceWarning
                                          // low performance warning
                                          ? Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.speed,
                                                    size: maxDimention / 3,
                                                    color: Colors.black,
                                                  ),
                                                  SizedBox(
                                                    width: maxDimention / 3 * 2,
                                                    child: const Text(
                                                      "Your device has been detected to have low performance, the QR code scanner may not work.",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(color: Colors.black),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 8.0),
                                                    child: SizedBox(
                                                      width: maxDimention / 3 * 2,
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.max,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          TextButton(
                                                            style: ButtonStyle(
                                                              foregroundColor: WidgetStatePropertyAll(
                                                                HSLColor.fromColor(
                                                                        Theme.of(context).colorScheme.primary)
                                                                    .withLightness(0.4)
                                                                    .toColor(),
                                                              ),
                                                            ),
                                                            child: const Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Icon(Icons.arrow_forward),
                                                                Gap(4.0),
                                                                Text("Continue"),
                                                              ],
                                                            ),
                                                            onPressed: () {
                                                              setState(() {
                                                                showLowPerformanceWarning = false;
                                                              });
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : importingData
                                              // loader while importing data
                                              ? const Center(
                                                  child: CircularProgressIndicator(),
                                                )
                                              : unknownCameraError
                                                  // unknown camera error
                                                  ? cameraError(
                                                      "Unknown camera error!",
                                                      () {
                                                        setState(() {
                                                          unknownCameraError = false;
                                                        });
                                                      },
                                                    )
                                                  : cameraDenied
                                                      // camera access denied
                                                      ? cameraError(
                                                          "Camera permission denied!",
                                                          () {
                                                            setState(() {
                                                              cameraDenied = false;
                                                            });
                                                          },
                                                        )
                                                      // qr reader
                                                      : Stack(
                                                          children: [
                                                            Opacity(
                                                              opacity: cameraReady ? 1 : 0,
                                                              child: Container(
                                                                clipBehavior: Clip.antiAlias,
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(16),
                                                                ),
                                                                child: Stack(
                                                                  children: [
                                                                    ReaderWidget(
                                                                      codeFormat: Format.qrCode,
                                                                      onScan: _onScanSuccess,
                                                                      onScanFailure: _onScanFailure,
                                                                      onControllerCreated: _onControllerCreated,
                                                                      scanDelay: const Duration(milliseconds: 100),
                                                                      scanDelaySuccess:
                                                                          const Duration(milliseconds: 500),
                                                                      allowPinchZoom: true,
                                                                      isMultiScan: false,
                                                                      showGallery: false,
                                                                      showFlashlight: false,
                                                                      showToggleCamera: true,
                                                                      actionButtonsAlignment: Alignment.bottomRight,
                                                                      resolution: ResolutionPreset.high,
                                                                      lensDirection: CameraLensDirection.back,
                                                                      toggleCameraIcon: const Icon(Icons.cameraswitch),
                                                                      showScannerOverlay: false,
                                                                      cropPercent: 1,
                                                                      actionButtonsBackgroundBorderRadius:
                                                                          BorderRadius.circular(16),
                                                                      actionButtonsBackgroundColor:
                                                                          Colors.black.withOpacity(0.4),
                                                                      tryHarder: false,
                                                                    ),
                                                                    if (cameraReady && scannedNumSplit > 1)
                                                                      Positioned(
                                                                        left: -1,
                                                                        right: -1,
                                                                        top: 0,
                                                                        child: LinearProgressIndicator(
                                                                          value: scannedSplit.length / scannedNumSplit,
                                                                          minHeight: 16,
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            if (!cameraReady)
                                                              const Center(
                                                                child: CircularProgressIndicator(),
                                                              ),
                                                          ],
                                                        )
                                      // import tab not visible
                                      : Container()
                                  // qr scanning not supported
                                  : Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.videocam_off,
                                            size: maxDimention / 3,
                                            color: Colors.black,
                                          ),
                                          SizedBox(
                                            width: maxDimention / 3 * 2,
                                            child: const Text(
                                              "QR scanning is not supported on this device",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: Colors.black),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                            // paste button
                            const Gap(8.0),
                            SizedBox(
                              height: 38.0,
                              child: importingData
                                  ? null
                                  : FilledButton(
                                      style: const ButtonStyle(
                                        padding: WidgetStatePropertyAll(
                                          EdgeInsets.symmetric(
                                            vertical: 2.0,
                                            horizontal: 20.0,
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          importingData = true;
                                        });
                                        var data = await Clipboard.getData("text/plain");
                                        useUrl(data?.text);
                                      },
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.paste,
                                            size: 20,
                                          ),
                                          Gap(8.0),
                                          Text("Paste"),
                                        ],
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
