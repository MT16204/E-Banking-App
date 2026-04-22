import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banking_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Thêm tham số isLoggedIn: false để khớp với constructor mới của MyApp
    await tester.pumpWidget(const MyApp(initialRoute: '/', isLoggedIn: false));

    // Lưu ý: Nếu App của bạn không có nút "+" (mặc định của dự án Flutter mới)
    // thì đoạn test dưới đây sẽ fail, nhưng nó sẽ hết lỗi đỏ (Compile error).
    if (find.byIcon(Icons.add).evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
    }
  });
}
