// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:banking_app/main.dart';

// void main() {
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     // Thêm tham số isLoggedIn: false để khớp với constructor mới của MyApp
//     await tester.pumpWidget(const MyApp(initialRoute: '/', isLoggedIn: false));

//     // Lưu ý: Nếu App của bạn không có nút "+" (mặc định của dự án Flutter mới)
//     // thì đoạn test dưới đây sẽ fail, nhưng nó sẽ hết lỗi đỏ (Compile error).
//     if (find.byIcon(Icons.add).evaluate().isNotEmpty) {
//       await tester.tap(find.byIcon(Icons.add));
//       await tester.pump();
//     }
//   });
// }

import 'package:banking_app/features/auth/screens/login_screen.dart';
import 'package:banking_app/providers/appearance_provider.dart';
import 'package:banking_app/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:banking_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppearanceProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          // Nếu sau này có thêm AuthProvider hay các cái khác, hãy thêm vào đây
        ],
        child: const MyApp(initialRoute: '/', isLoggedIn: false),
      ),
    );

    // Chờ SplashScreen và các transition hoàn tất
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget); 
  });
}