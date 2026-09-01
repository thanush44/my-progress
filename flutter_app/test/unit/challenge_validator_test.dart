import 'package:flutter_test/flutter_test.dart';

bool validateChallenge(String input, String target) {
  final normalizedInput = input.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  final normalizedTarget = target.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  return normalizedInput == normalizedTarget;
}

void main() {
  group('Challenge Validator Tests', () {
    const target = 'I will stay consistent with my goals and complete my daily work today.';

    test('exact match passes', () {
      expect(validateChallenge(target, target), isTrue);
    });

    test('case-insensitive match passes', () {
      expect(validateChallenge(target.toUpperCase(), target), isTrue);
      expect(validateChallenge(target.toLowerCase(), target), isTrue);
    });

    test('ignores extra whitespace between words and leading/trailing whitespace', () {
      const inputWithSpaces = '  I   will   stay   consistent   with my goals and complete my daily work today.   ';
      expect(validateChallenge(inputWithSpaces, target), isTrue);
    });

    test('fails on typo or missing word', () {
      const typoInput = 'I will stay consistent with goals and complete my daily work today.';
      expect(validateChallenge(typoInput, target), isFalse);
    });

    test('fails on empty or partial input', () {
      expect(validateChallenge('', target), isFalse);
      expect(validateChallenge('I will stay consistent', target), isFalse);
    });
  });
}
