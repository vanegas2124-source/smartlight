import 'package:flutter_test/flutter_test.dart';
import 'package:smartlight_enterprise/app/app.dart';

void main() {
  test('SmartLightApp puede crearse correctamente', () {
    const app = SmartLightApp();

    expect(app, isA<SmartLightApp>());
  });
}
