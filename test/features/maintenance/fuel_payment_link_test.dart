import 'package:fines_plus/features/maintenance/domain/fuel_payment_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  double? amountOf(String amount) =>
      FuelPaymentLink.amountFrom(Uri.parse('com.finesplus://fuel?amount=${Uri.encodeQueryComponent(amount)}'));

  group('FuelPaymentLink.matches', () {
    test('matches the custom-scheme fuel link', () {
      expect(FuelPaymentLink.matches(Uri.parse('com.finesplus://fuel?amount=1')), isTrue);
    });

    test('ignores web links and other hosts', () {
      expect(FuelPaymentLink.matches(Uri.parse('https://fuel/?amount=1')), isFalse);
      expect(FuelPaymentLink.matches(Uri.parse('https://finesplus.web.app/addCar.html')), isFalse);
      expect(FuelPaymentLink.matches(Uri.parse('myapp://addexp/5')), isFalse);
    });
  });

  group('FuelPaymentLink.amountFrom', () {
    test('parses plain numbers', () {
      expect(amountOf('1250.5'), 1250.5);
      expect(amountOf('800'), 800);
    });

    test('parses Shortcuts currency text', () {
      expect(amountOf('1 250,50 ₴'), 1250.5);
      expect(amountOf('₴1,250.50'), 1250.5);
      expect(amountOf('\$1,250'), 1250);
      expect(amountOf('1.250,75 €'), 1250.75);
      expect(amountOf('1250,5'), 1250.5);
    });

    test('returns null when missing or not positive', () {
      expect(FuelPaymentLink.amountFrom(Uri.parse('com.finesplus://fuel')), isNull);
      expect(amountOf('abc'), isNull);
      expect(amountOf('0'), isNull);
    });
  });
}
