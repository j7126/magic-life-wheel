import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:magic_life_wheel/datamodel/player.dart';
import 'package:magic_life_wheel/service/static_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as scanner;
import 'package:tab_container/tab_container.dart';

class TransferGameDialog extends StatefulWidget {
  const TransferGameDialog({
    super.key,
    required this.players,
    required this.layoutId,
  });

  final List<Player> players;
  final int layoutId;

  @override
  State<TransferGameDialog> createState() => _TransferGameDialogState();
}

class _TransferGameDialogState extends State<TransferGameDialog> with WidgetsBindingObserver {
  bool firstRender = true;
  bool ready = false;
  bool importingData = false;
  late String data;

  final scanner.MobileScannerController? _scannerController = Service.supportScanner
      ? scanner.MobileScannerController(
          formats: [scanner.BarcodeFormat.qrCode],
        )
      : null;

  StreamSubscription<Object?>? _scannerSubscription;

  void buildQrData() async {
    await Future.delayed(const Duration(milliseconds: 200));
    data = await compute(
      (d) {
        var p = d.$1;
        var layoutId = d.$2;
        var players = p.map((e) {
          var jsonMap = e.toJson();
          var bg = (jsonMap["background"] as Map<String, dynamic>);
          bg.remove("_customImage");
          if (bg["_card"] != null) {
            bg["_card"] = bg["_card"]["uuid"];
          }
          if (bg["_cardPartner"] != null) {
            bg["_cardPartner"] = bg["_cardPartner"]["uuid"];
          }
          return jsonMap;
        }).toList();
        var resultMap = <String, dynamic>{};
        resultMap["players"] = players;
        resultMap["layoutId"] = layoutId;
        var jsonResult = jsonEncode(resultMap);
        var jsonResultUtf8 = utf8.encode(jsonResult);
        var gzipJsonResult = gzip.encode(jsonResultUtf8);
        var base64Result = base64.encode(gzipJsonResult);
        return "${Service.appBaseUrl}$base64Result";
      },
      (widget.players, widget.layoutId),
    );
    setState(() {
      ready = true;
    });
  }

  void _handleBarcode(scanner.BarcodeCapture capture) {}

  void dataError() {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The game data was not valid!'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 58.0),
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (_scannerController == null || !_scannerController.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _scannerSubscription = _scannerController.barcodes.listen(_handleBarcode);
        unawaited(_scannerController.start());
      case AppLifecycleState.inactive:
        await _scannerSubscription?.cancel();
        _scannerSubscription = null;
        unawaited(_scannerController.stop());
    }
  }

  @override
  void initState() {
    super.initState();
    if (Service.supportScanner && _scannerController != null) {
      WidgetsBinding.instance.addObserver(this);
      _scannerSubscription = _scannerController.barcodes.listen(_handleBarcode);
      unawaited(_scannerController.start());
    }
  }

  @override
  Future<void> dispose() async {
    if (Service.supportScanner && _scannerController != null) {
      WidgetsBinding.instance.removeObserver(this);
      await _scannerSubscription?.cancel();
      _scannerSubscription = null;
      await _scannerController.dispose();
    }
    super.dispose();
  }

  void useData(String? data) {
    setState(() {
      importingData = true;
    });
    if (data != null && data.startsWith(Service.appBaseUrl)) {
    } else {
      dataError();
    }
    setState(() {
      importingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (firstRender) {
      firstRender = false;
      buildQrData();
    }

    var hasCustomImage = widget.players.any((x) => x.background.customImage != null);

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var maxContentWidth = width - 96.0 - 48;
    var maxContentHeight = height - 366 - (hasCustomImage ? 48.0 : 0.0);
    var maxDimention = min(maxContentHeight, maxContentWidth);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: GestureDetector(
          onTap: () {},
          child: AlertDialog(
            insetPadding: const EdgeInsets.all(32.0),
            titlePadding: const EdgeInsets.only(top: 12.0, left: 20.0, right: 12.0),
            contentPadding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0, top: 8.0),
            title: Row(
              children: [
                const Text("Transfer Game"),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Transfer the current game to another device.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (hasCustomImage)
                    const Card(
                      margin: EdgeInsets.only(top: 8.0),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline),
                            Gap(8.0),
                            Text("Custom images will not be transfered."),
                          ],
                        ),
                      ),
                    ),
                  const Gap(16.0),
                  TabContainer(
                    tabEdge: TabEdge.top,
                    borderRadius: BorderRadius.circular(10),
                    tabBorderRadius: BorderRadius.circular(10),
                    childPadding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 12.0),
                    selectedTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 15.0,
                    ),
                    unselectedTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 13.0,
                    ),
                    color: Theme.of(context).colorScheme.background,
                    tabs: const [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.call_made),
                          Gap(8.0),
                          Text('Send'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.call_received),
                          Gap(8.0),
                          Text('Import'),
                        ],
                      ),
                    ],
                    children: [
                      Column(
                        children: [
                          Text(
                            "Use the \"Import\" tab to scan this QR code on the other device.",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const Gap(8.0),
                          SizedBox(
                            width: maxDimention,
                            height: maxDimention,
                            child: ready
                                ? BarcodeWidget(
                                    barcode: Barcode.qrCode(),
                                    data: data,
                                    backgroundColor: Colors.white,
                                    padding: EdgeInsets.all(maxDimention * 0.03 + 2),
                                  )
                                : const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: SizedBox(
                              height: 32.0,
                              child: ready
                                  ? TextButton(
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
                                          Icon(Icons.copy),
                                          Gap(8.0),
                                          Text("Copy"),
                                        ],
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "Scan the QR code displayed on the other device.",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const Gap(8.0),
                          SizedBox(
                            width: maxDimention,
                            height: maxDimention,
                            child: Service.supportScanner
                                ? scanner.MobileScanner(
                                    controller: _scannerController,
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.videocam_off,
                                          size: maxDimention / 3,
                                        ),
                                        SizedBox(
                                          width: maxDimention / 3 * 2,
                                          child: const Text(
                                            "QR scanning is not supported on this device",
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: SizedBox(
                              height: 32.0,
                              child: importingData
                                  ? null
                                  : TextButton(
                                      onPressed: () async {
                                        setState(() {
                                          importingData = true;
                                        });
                                        var data = await Clipboard.getData("text/plain");
                                        useData(data?.text);
                                      },
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.paste),
                                          Gap(8.0),
                                          Text("Paste"),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
