import 'package:flutter_test/flutter_test.dart';
import 'package:kinder_world/core/utils/password_policy.dart';

void main() {
  test(
      'password policy accepts passwords that satisfy creation and change rules',
      () {
    expect(PasswordPolicy.isSatisfied('StrongPass1!'), isTrue);
  });

  test('password policy rejects short passwords', () {
    expect(PasswordPolicy.isSatisfied('Ab1!xyz'), isFalse);
  });

  test('password policy rejects passwords without uppercase letter', () {
    expect(PasswordPolicy.isSatisfied('strongpass1!'), isFalse);
  });

  test('password policy rejects passwords without number', () {
    expect(PasswordPolicy.isSatisfied('StrongPass!'), isFalse);
  });

  test('password policy rejects passwords without special character', () {
    expect(PasswordPolicy.isSatisfied('StrongPass1'), isFalse);
  });
}
