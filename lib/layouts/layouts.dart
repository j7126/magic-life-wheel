import 'package:magic_life_wheel/layouts/layout.dart';
import 'package:magic_life_wheel/layouts/layout_2a.dart';
import 'package:magic_life_wheel/layouts/layout_3a.dart';
import 'package:magic_life_wheel/layouts/layout_3b.dart';
import 'package:magic_life_wheel/layouts/layout_4a.dart';
import 'package:magic_life_wheel/layouts/layout_4b.dart';
import 'package:magic_life_wheel/layouts/layout_5a.dart';
import 'package:magic_life_wheel/layouts/layout_5b.dart';
import 'package:magic_life_wheel/layouts/layout_6a.dart';
import 'package:magic_life_wheel/layouts/layout_6b.dart';

class Layouts {
  static List<Layout> get layouts => [
        Layout2a(),
        Layout3a(),
        Layout3b(),
      ];

  static Map<int, List<Layout>> get layoutsBySize => {
        2: [
          Layout2a(),
        ],
        3: [
          Layout3a(),
          Layout3b(),
        ],
        4: [
          Layout4a(),
          Layout4b(),
        ],
        5: [
          Layout5a(),
          Layout5b(),
        ],
        6: [
          Layout6a(),
          Layout6b(),
        ]
      };
}
