import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vien_mvp/screens/exploration_tasks_screen.dart';
import 'package:vien_mvp/screens/home_screen.dart';
import 'package:vien_mvp/screens/hue_dashboard_screen.dart';
import 'package:vien_mvp/screens/register_screen.dart';
import 'package:vien_mvp/services/local_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tapping community chat opens the chat screen', (tester) async {
    SharedPreferences.setMockInitialValues({
      'user_email': 'explorer@example.com',
      'user_points': 120,
      'user_title': 'Người Gác Thành Đội Viên ⚔️',
    });

    final localService = LocalService();
    await localService.saveUserData('explorer@example.com', 120);

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(localService: localService)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Trò Chuyện Cộng Đồng'), findsOneWidget);

    await tester.tap(find.text('Trò Chuyện Cộng Đồng'));
    await tester.pumpAndSettle();

    expect(find.text('Box Chat Cộng Đồng'), findsOneWidget);
  });

  testWidgets('hue dashboard verifies location before opening attraction', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    final localService = LocalService();
    await localService.saveUserData('explorer@example.com', 120);

    await tester.pumpWidget(
      MaterialApp(home: HueDashboardScreen(localService: localService)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Đại Nội Huế'));
    await tester.pump();

    expect(
      find.text('Hệ thống đang xác thực tọa độ GPS của bạn tại Đại Nội Huế...'),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(
      find.text('Xác thực thành công! Bạn đã đến đúng vị trí di sản. 🎉'),
      findsOneWidget,
    );
  });

  testWidgets('exploration tasks screen shows the end journey button', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    final localService = LocalService();
    await localService.saveUserData('explorer@example.com', 400);

    await tester.pumpWidget(
      MaterialApp(
        home: ExplorationTasksScreen(
          localService: localService,
          attractionTitle: 'Đại Nội Huế',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('KẾT THÚC HÀNH TRÌNH'), findsOneWidget);
  });

  testWidgets('register screen saves mock credentials and shows success', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    final localService = LocalService();

    await tester.pumpWidget(
      MaterialApp(home: RegisterScreen(localService: localService)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Họ và tên'),
      'An Nguyễn',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'an@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mật khẩu'),
      '123456',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Xác nhận mật khẩu'),
      '123456',
    );

    await tester.tap(find.text('ĐĂNG KÝ TÀI KHOẢN'));
    await tester.pumpAndSettle();

    expect(find.text('Tạo tài khoản thành công! 🎉'), findsOneWidget);
  });

  test('local service persists completed task ids', () async {
    SharedPreferences.setMockInitialValues({});

    final localService = LocalService();
    await localService.saveCompletedTasks(['task_0', 'task_2']);

    await expectLater(
      localService.getCompletedTaskIds(),
      completion(equals(['task_0', 'task_2'])),
    );
  });
}
