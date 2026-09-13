import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bigpay/ui/components/forms/phone_input.dart';

CountryWithPhoneCode _country({
  required String phoneCode,
  required String countryCode,
  String nationalMask = '000 000 0000',
}) {
  return CountryWithPhoneCode(
    phoneCode: phoneCode,
    countryCode: countryCode,
    exampleNumberMobileNational: '',
    exampleNumberFixedLineNational: '',
    phoneMaskMobileNational: nationalMask,
    phoneMaskFixedLineNational: nationalMask,
    exampleNumberMobileInternational: '',
    exampleNumberFixedLineInternational: '',
    phoneMaskMobileInternational: '+$phoneCode $nationalMask',
    phoneMaskFixedLineInternational: '+$phoneCode $nationalMask',
    countryName: countryCode,
  );
}

void main() {
  group('PhoneNumberController', () {
    test('converts a Ghana national number to international format', () {
      final controller = PhoneNumberController(
        country: _country(phoneCode: '233', countryCode: 'GH'),
        national: '0243505598',
      );

      expect(controller.international, '233243505598');
      expect(controller.isValid, isTrue);
    });

    test('a partial number is not valid', () {
      final controller = PhoneNumberController(
        country: _country(phoneCode: '233', countryCode: 'GH'),
        national: '02435',
      );

      expect(controller.isValid, isFalse);
    });

    test('an empty number reports valid via validator (not required here)', () {
      final controller = PhoneNumberController(
        country: _country(phoneCode: '233', countryCode: 'GH'),
      );

      expect(controller.validator('invalid')(null), isNull);
    });

    test(
      'a country with no leading trunk 0 (e.g. US-style) is passed through',
      () {
        final controller = PhoneNumberController(
          country: _country(
            phoneCode: '1',
            countryCode: 'US',
            nationalMask: '(000) 000-0000',
          ),
          national: '2015550123',
        );

        expect(controller.international, '12015550123');
      },
    );

    test('switching country clears the previously typed digits', () {
      final gh = _country(phoneCode: '233', countryCode: 'GH');
      final us = _country(
        phoneCode: '1',
        countryCode: 'US',
        nationalMask: '(000) 000-0000',
      );
      final controller = PhoneNumberController(
        country: gh,
        national: '0243505598',
      );

      controller.country = us;

      expect(controller.text.text, isEmpty);
      expect(controller.country.countryCode, 'US');
    });
  });

  group('countryFlagEmoji', () {
    test('maps a two-letter country code to its flag', () {
      expect(countryFlagEmoji('GH'), '🇬🇭');
      expect(countryFlagEmoji('gh'), '🇬🇭');
    });
  });
}
