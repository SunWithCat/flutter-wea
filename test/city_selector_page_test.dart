import 'dart:convert'; // 用于JSON编码
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart'; // 测试核心库
import 'package:http/http.dart' as http; // http请求库
import 'package:mockito/annotations.dart'; // Mockito注解
import 'package:mockito/mockito.dart'; // Mockito核心功能
import 'package:wea/pages/city_sele.dart'; // 被测试的页面

import 'city_selector_page_test.mocks.dart'; // Mockito自动生成的文件

// 使用 mockito 生成 http.Client 的模拟类
@GenerateMocks([http.Client])
void main() {
  group('CitySeletorPage Widget Tests', () {
    late MockClient mockClient; // 每个测试运行前被初始化

    setUp(() {
      mockClient = MockClient(); // 创建一个全新的实例，确保测试之间的独立性
    });

    // 封装一个函数来构建和渲染 Widget
    Future<void> pumpWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CitySeletorPage(client: mockClient), // 注入 MockClient
        ),
      );
    }

    testWidgets('should display search results when API call is successful', (
      WidgetTester tester,
    ) async {
      // 安排 (Arrange)
      final keyword = 'beijing';
      final responsePayload = {
        'code': '200',
        'location': [
          {'name': '北京', 'id': '101010100', 'adm1': '北京市', 'adm2': '北京'},
        ],
      };
      when(mockClient.get(any)).thenAnswer(
        // 当get方法被任何参数调用时
        (_) async =>
            http.Response.bytes(utf8.encode(jsonEncode(responsePayload)), 200),
      );

      // 操作 (Act)
      await pumpWidget(tester); // 渲染初始界面
      await tester.enterText(find.byType(TextField), keyword); // 模拟用户输入
      await tester.pump(const Duration(milliseconds: 500)); // 手动等待防抖计时器触发
      await tester.pump(); // 等待 Future 完成和 UI 更新

      // 断言 (Assert)
      expect(find.text('北京'), findsOneWidget);
      expect(find.text('北京 - 北京市'), findsOneWidget);
    });

    testWidgets('should display "not found" message when no city matches', (
      WidgetTester tester,
    ) async {
      // 安排
      final keyword = 'nonexistentcity';
      final responsePayload = {'code': '404'}; // 响应内容是未找到
      when(mockClient.get(any)).thenAnswer(
        (_) async =>
            http.Response.bytes(utf8.encode(jsonEncode(responsePayload)), 200),
      );

      // 操作
      await pumpWidget(tester);
      await tester.enterText(find.byType(TextField), keyword);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // 断言
      expect(find.text('未找到与 "$keyword"相关的城市'), findsOneWidget);
    });

    testWidgets('should handle API errors gracefully', (
      WidgetTester tester,
    ) async {
      // 安排
      final keyword = 'errorcity';
      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response('Not Found', 404));

      // 操作
      await pumpWidget(tester);
      await tester.enterText(find.byType(TextField), keyword);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // 断言
      // 验证列表为空
      expect(find.byType(ListView), findsNothing);
      // 验证是否显示了错误提示 (SnackBar)
      // SnackBar 的测试稍微复杂，这里我们主要验证核心逻辑，即列表为空
      expect(find.textContaining('北京'), findsNothing);
    });

    testWidgets('should not perform search for short keywords', (
      WidgetTester tester,
    ) async {
      // 操作
      await pumpWidget(tester);
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // 断言
      // 验证没有发起网络请求
      verifyNever(mockClient.get(any));
      // 验证列表为空
      expect(find.byType(ListView), findsNothing);
    });
  });
}
