// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leek/main.dart';

void main() {
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(MyApp());

  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);

  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();

  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });

  testWidgets('json序列化', (WidgetTester tester) async {
    // final parser = RSAKeyParser();
    // RSAPublicKey publicKey = parser.parse("MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDr+R+gyG8kwhK0UZ0sI4FIjN1wsFh5GtU0dzwqEADgw68wQLQUe8t0syYFtxbLQRfrsoj2t6vredqQXaBMkGLX+9rLuSMez8qmZ676r89Ywy8g9kGHDsWUJY1jazENmMF7n/rNxb/7F7vHhzDJVgdCz6rqaCHMlsEhvdX1qAATqwIDAQAB");
    // final encrypter = Encrypter(RSA(publicKey: publicKey));
    // print(encrypter.encrypt("hello"));
  });

  testWidgets('加密', (WidgetTester tester) async {
    final publicKey = '...';
    final privateKey = '...';
    var plainText = 'something';
    // final encryptedText =
    //     await encryptString(plainText, utf8.decode(base64.decode(publicKey)));
    // final decryptedText = await decryptString(
    //     encryptedText, utf8.decode(base64.decode(privateKey)));
  });
}
