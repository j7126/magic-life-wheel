class CounterFontSizeGroup {
  CounterFontSizeGroup();

  final List<double> _sizes = [];

  double get minSize {
    var min = double.infinity;
    for (var x in _sizes) {
      if (x < min) {
        min = x;
      }
    }
    return min;
  }

  void setSize(int i, double size) {
    while (_sizes.length <= i) {
      _sizes.add(double.maxFinite);
    }
    _sizes[i] = size;
  }

  void setNumPlayers(int n) {
    while (_sizes.length > n) {
      _sizes.removeAt(_sizes.length - 1);
    }
  }
}
