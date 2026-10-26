import 'package:fines_plus/features/maintenance/data/insurance_policy_lookup.dart';
import 'package:fines_plus/features/maintenance/domain/insurance_policy_page_parser.dart';
import 'package:flutter_test/flutter_test.dart';

const _page = '''
<html><head><style>.a{color:red}</style><script>var x = "Найменування";</script></head><body>
<h1>Електронний поліс № 123456789</h1>
<div><span>Найменування</span></div>
<div><b>ТДВ &quot;Тест Страхування&quot;</b></div>
<div><span>Дата та час початку строку дії Договору</span></div>
<div>З 00:00, 10.11.2025</div>
<div><span>Дата закінчення строку дії Договору</span></div>
<div>До 23:59, 09.11.2026 включно</div>
<div><span>Реєстраційний номер</span></div>
<div>AB1234CD</div>
</body></html>
''';

void main() {
  test('decodes numeric character references', () {
    final page = _page.replaceAll('ТДВ &quot;Тест Страхування&quot;', '&#x422;&#x414;&#x412; &quot;&#1058;&#x435;&#x441;&#x442;&quot;');
    expect(InsurancePolicyPageParser.parse(page)!.company, 'ТДВ "Тест"');
  });

  test('reads number, company, dates and plate off the policy page', () {
    final policy = InsurancePolicyPageParser.parse(_page)!;
    expect(policy.policyNumber, '123456789');
    expect(policy.company, 'ТДВ "Тест Страхування"');
    expect(policy.validFrom, DateTime(2025, 11, 10));
    expect(policy.validTo, DateTime(2026, 11, 9));
    expect(policy.plate, 'AB1234CD');
  });

  test('returns null for a page that is not a policy', () {
    expect(InsurancePolicyPageParser.parse('<html><body>Not found</body></html>'), isNull);
    expect(InsurancePolicyPageParser.parse(_page.replaceAll('Найменування', 'Name')), isNull);
  });

  test('plate matching ignores Latin/Cyrillic look-alikes and case', () {
    final policy = InsurancePolicyPageParser.parse(_page)!;
    expect(policy.matchesPlate('АВ1234СD'), isTrue);
    expect(policy.matchesPlate('ab1234cd'), isTrue);
    expect(policy.matchesPlate('AB1234CE'), isFalse);
    expect(policy.matchesPlate(''), isTrue);
  });

  test('only https registry pages are fetched', () {
    expect(InsurancePolicyLookup.isPolicyUrl('https://qr.eua.in.ua/DXHM7KT'), isTrue);
    expect(InsurancePolicyLookup.isPolicyUrl('https://policy.mtsbu.ua/qr/policyinfo/ua?md=AB'), isTrue);
    expect(InsurancePolicyLookup.isPolicyUrl('http://qr.eua.in.ua/DXHM7KT'), isFalse);
    expect(InsurancePolicyLookup.isPolicyUrl('https://evil.example.com/qr.eua.in.ua'), isFalse);
    expect(InsurancePolicyLookup.isPolicyUrl('https://eua.in.ua.evil.com/x'), isFalse);
    expect(InsurancePolicyLookup.isPolicyUrl('not a url'), isFalse);
  });
}
