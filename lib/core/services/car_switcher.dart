class CarSwitcher {
  String currentCar = '';

  final List<void Function(String)> _listeners = [];

  void register(void Function(String) listener) {
    _listeners.add(listener);
  }

  void changeCar(String newCar) {
    if (newCar == currentCar) return;
    currentCar = newCar;

    for (final listener in _listeners) {
      listener(newCar);
    }
  }
}
