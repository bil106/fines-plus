class CarNumberNormalizer {
  static const _map = {
    'А': 'A',
    'В': 'B',
    'Е': 'E',
    'К': 'K',
    'М': 'M',
    'Н': 'H',
    'О': 'O',
    'Р': 'P',
    'С': 'C',
    'Т': 'T',
    'Х': 'X',
  };
  static const _toCyrillic = {
    'A': 'А',
    'B': 'В',
    'E': 'Е',
    'K': 'К',
    'M': 'М',
    'H': 'Н',
    'O': 'О',
    'P': 'Р',
    'C': 'С',
    'T': 'Т',
    'X': 'Х',
  };
static String normalize(String input) {
    return input.toUpperCase().replaceAll(RegExp(r'[^A-ZА-Я0-9]'), '').split('').map((c) => _map[c] ?? c).join();
  }

    static String denormalize(String input) {
    return input.split('').map((c) => _toCyrillic[c] ?? c).join();
  }
}
